library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity project_reti_logiche is
port (
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_start : in std_logic;
    i_data : in std_logic_vector(7 downto 0);
    o_address : out std_logic_vector(15 downto 0);
    o_done : out std_logic;
    o_en : out std_logic;
    o_we : out std_logic;
    o_data : out std_logic_vector (7 downto 0)
);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type state_type_fsm_status is (IDLE, START, WAIT_W, SAVE_W, READ_VALUE, WAIT_VALUE, SAVE_VALUE, ELABORATE, WRITE_VALUE, FINE);
    type state_type_fsm_result is (S0, S1, S2, S3);
    
    signal W: unsigned(7 downto 0) := "00000000";
    signal resReady: std_logic := '0';
    signal addrRead: unsigned(7 downto 0) := "00000000";
    signal currentState: state_type_fsm_result := S0;
    signal action: state_type_fsm_status := IDLE ;
    signal res: std_logic_vector(15 downto 0) := "0000000000000000";
    signal count: unsigned(2 downto 0) := "111";
    signal tmp: std_logic_vector(15 downto 0) := "0000000000000001";        
    signal dato: std_logic_vector(7 downto 0) := "00000000";
    signal addrW: std_logic_vector(15 downto 0) := "0000001111101000";
    signal countW: std_logic_vector(1 downto 0) := "00";
    signal tmp1: unsigned(3 downto 0) := "1111";
    signal tmp2: unsigned(3 downto 0) := "1110";
begin
    fsm_Status: process(i_start, i_clk, i_rst, action, addrRead , countW, resReady)
    begin
    if(rising_edge(i_clk)) then
        if(i_rst = '1')then
            action <= IDLE;
        else
            case action is
                when IDLE =>
                    if(i_start = '1')then
                        action <= START;
                    else
                        action <= IDLE;
                    end if;
                when START =>                    
                    o_address <= "0000000000000000";        
                    o_en <= '1';
                    o_we <= '0';
                    tmp <= "0000000000000001";              
                    addrW <= "0000001111101000";            
                    addrRead <= "00000000";                 
                    action <= WAIT_W ;
                when WAIT_W => 
                    o_en <= '0';
                    action <= SAVE_W;
                when SAVE_W =>
                    W <= unsigned(i_data);
                    action <= READ_VALUE ;
                when READ_VALUE =>
                    if(addrRead < W)then
                        addrRead <= addrRead + 1; 
                        o_address <= tmp;
                        o_en <= '1';
                        o_we <= '0';
                        tmp <= tmp + 1; 
                        action <= WAIT_VALUE;
                    else
                        o_done <= '1';
                        action <= FINE;
                   end if;
                when WAIT_VALUE =>
                    o_en <= '0';
                    action <= SAVE_VALUE ;
                when SAVE_VALUE =>
                    dato <= i_data;
                    action <= ELABORATE;
                when ELABORATE =>
                    if(resReady = '1')then
                        action <= WRITE_VALUE;
                    else 
                        action <= ELABORATE;
                    end if;
                when WRITE_VALUE =>
                    o_en <= '1';
                    o_we <= '1';
                    if(countW < "10")then
                        if(countW = "00")then
                            o_data <= res(15 downto 8);
                        else
                            o_data <= res(7 downto 0);
                        end if;
                        o_address <= addrW;
                        addrW <= addrW + 1;
                        countW <= countW + 1;
                    else
                        countW <= "00";
                        action <= READ_VALUE;
                    end if;
                WHEN FINE => 
                    if(i_start = '0')then
                        o_done <= '0';
                        action <= IDLE;
                    else
                        action <= FINE;
                    end if;
            end case;                
        end if;
     end if;
   end process fsm_Status;
   
   fsm_Result: process(i_clk, i_rst, action, resReady , i_start, count, dato)
   begin
   if(rising_edge(i_clk)) then
    if(i_start = '0' or i_rst = '1')then
        currentState <= S0;
    else
       if(resReady = '1')then
           resReady <= '0';
        elsif(action = ELABORATE)then
            case currentState is
                when S0 => 
                     if(dato(to_integer(count)) = '0') then
                        res(to_integer(tmp1)) <= '0';
                        res(to_integer(tmp2)) <= '0';
                        currentState <= S0;
                     else 
                        res(to_integer(tmp1)) <= '1';
                        res(to_integer(tmp2)) <= '1';
                        currentState <= S2;
                     end if;
                 when S1 => 
                    if (dato(to_integer(count)) = '0') then
                        res(to_integer(tmp1)) <= '1';
                        res(to_integer(tmp2)) <= '1';
                        currentState <= S0;
                    else 
                        res(to_integer(tmp1)) <= '0';
                        res(to_integer(tmp2)) <= '0';
                        currentState <= S2;
                    end if;
                 when S2 => 
                    if(dato(to_integer(count)) = '0') then 
                        res(to_integer(tmp1)) <= '0';
                        res(to_integer(tmp2)) <= '1';
                        currentState <= S1;
                    else 
                        res(to_integer(tmp1)) <= '1';
                        res(to_integer(tmp2)) <= '0';
                        currentState <= S3;
                    end if;
                 when S3 => 
                    if(dato(to_integer(count)) = '0') then
                        res(to_integer(tmp1)) <= '1';
                        res(to_integer(tmp2)) <= '0';
                        currentState <= S1;
                    else 
                        res(to_integer(tmp1)) <= '0';
                        res(to_integer(tmp2)) <= '1';
                        currentState <= S3;
                    end if;
               end case;
               if(count = "000")then
                    resReady <= '1';
                    count <= "111";
                    tmp1 <= "1111";
                    tmp2 <= "1110";
               else 
                   count <= count - 1;
                   tmp1 <= tmp1 - 2;
                   tmp2 <= tmp2 - 2;
               end if;
           end if;
         end if;
      end if;
   end process fsm_result;
 end Behavioral;
