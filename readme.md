This project is a demo of UART Register. The register control the LED.

```
   |===========||                    
   |           ||
   |    PC     ||
   |           ||           |-------|   |---------| 
   /-----------//           |       |===|         |===7 SEG LED
  /           // TX---------| UART  |===| register|===7 SEG LED
 /           //  RX---------|       |===|         |===7 SEG LED
/===========|/              |       |===|         |===7 SEG LED
                            |_______|   |_________|
```
