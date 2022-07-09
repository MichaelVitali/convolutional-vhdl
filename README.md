<h2>Digital Logic Design Project</h2>
<h3> Convolutional ½</h3>

---

<h3>Specifiche di implementazione</h3>
Il modulo riceve in ingresso una sequenza continua di W parole, ognuna di 8 bit, e
restituisce in uscita una sequenza continua di Z parole, ognuna da 8 bit. Ognuna delle
parole di ingresso viene serializzata; in questo modo viene generato un flusso continuo U da
1 bit. Su questo flusso viene applicato il codice convoluzionale ½ (ogni bit viene codificato
con 2 bit) secondo lo schema riportato in figura; questa operazione genera in uscita un
flusso continuo Y. Il flusso Y è ottenuto come concatenamento alternato dei due bit di uscita.
Utilizzando la notazione riportata in figura, il bit uk genera i bit p1k e p2k che sono poi
concatenati per generare un flusso continuo yk (flusso da 1 bit). La sequenza d’uscita Z è la
parallelizzazione, su 8 bit, del flusso continuo yk.

![alt text](https://github.com/MichaelVitali/convolutional-vhdl/blob/main/images/convolutional.jpg?raw=true)

La lunghezza del flusso U è 8*W, mentre la lunghezza del flusso Y è 8*W*2 (Z=2*W).
Il convolutore è una macchina sequenziale sincrona con un clock globale e un segnale di
reset con il seguente diagramma degli stati che ha nel suo 00 lo stato iniziale, con uscite in
ordine P1K, P2K.

<h3>Macchina a stati del convolutore</h3>

![alt text](https://github.com/MichaelVitali/convolutional-vhdl/blob/main/images/state_machine_convolutional.jpg?raw=true)

<h3>Interfaccia del componente</h3>
Il componente da descrivere deve avere la seguente interfaccia:
<h4>entity project_reti_logiche is<br>
port (</h4>
- i_clk : in std_logic;<br>
- i_rst : in std_logic;<br>
- i_start : in std_logic;<br>
- i_data : in std_logic_vector(7 downto 0);<br>
- o_address : out std_logic_vector(15 downto 0);<br>
- o_done : out std_logic;<br>
- o_en : out std_logic;<br>
- o_we : out std_logic;<br>
- o_data : out std_logic_vector (7 downto 0)<br>
<h4>
);<br>
end project_reti_logiche;</h4><br>
