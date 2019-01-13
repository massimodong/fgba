# fgba

**This projects is a homework for the course "Digital circuits", and is stopped because the course ended.**  

Fgba intends to create a Gameboy Advance (gba) emulator on an fpga board.
It includes an armv4t CPU, various modules on the gba, and outputs through VGA on the left top corner of a screen.

## Environments & Language
- Intel cyclone V, 5CSXFC6D6F31C6
- Quartus v17.1 lite
- Verilog HDL

## Status

<table>
  <tr>
    <th colspan="2">Module</th>
    <th>Status</th>
  </tr>
  <tr>
    <td rowspan="3"> CPU </td>
    <td> architecture </td>
    <td> done </td>
  </tr>
  <tr>
    <td> ARM instruction set </td>
    <td> only SWI left. </td>
  </tr>
  <tr>
    <td> Thumb instruction set </td>
    <td> only SWI left. </td>
  </tr>
  <tr>
    <td rowspan="7"> Memory </td>
    <td> ROM </td>
    <td> done，copied from <a href="http://vba-m.com/"> http://vba-m.com/ </a></td>
  </tr>
  <tr>
    <td> Internal Working RAM </td>
    <td> done </td>
  </tr>
  <tr>
    <td> External Working RAM </td>
    <td> done </td>
  </tr>
  <tr>
    <td> Palette RAM </td>
    <td> done. But object is not yet implemented </td>
  </tr>
  <tr>
    <td> VRAM </td>
    <td> done </td>
  </tr>
  <tr>
    <td> OAM </td>
    <td> not started </td>
  </tr>
  <tr>
    <td> Game Pak </td>
    <td> currently using on chip memory, which has only 140kb left. SDRAM could be used to achieve a full 32Mb Game Pak </td>
  </tr>
  <tr>
    <td rowspan="9"> Image System </td>
    <td> mode 0 </td>
    <td> not started </td>
  </tr>
  <tr>
    <td> mode 1 </td>
    <td> not started </td>
  </tr>
  <tr>
    <td> mode 2 </td>
    <td> not started </td>
  </tr>
  <tr>
    <td> mode 3 </td>
    <td> done </td>
  </tr>
  <tr>
    <td> mode 4 </td>
    <td> done </td>
  </tr>
  <tr>
    <td> mode 5 </td>
    <td> not started </td>
  </tr>
  <tr>
    <td> Object </td>
    <td> not started </td>
  </tr>
  <tr>
    <td> Window </td>
    <td> not started </td>
  </tr>
  <tr>
    <td> Rotating/Scaling </td>
    <td> not started </td>
  </tr>
  <tr>
    <td rowspan="5"> others </td>
    <td> Sound </td>
    <td> not started </td>
  </tr>
  <tr>
    <td> Timer </td>
    <td> done </td>
  </tr>
  <tr>
    <td> DMA </td>
    <td> not started </td>
  </tr>
  <tr>
    <td> Key Input </td>
    <td> done </td>
  </tr>
  <tr>
    <td> Interrupt Control </td>
    <td> not started </td>
  </tr>
  <tr>
    <td rowspan="1"> Communication </td>
    <td> all </td>
    <td> not started </td>
  </tr>
  
</table>

## Usage

### compile
Just open the project using the Quartus software. If you wish to use other environments, it woild be easy to use our code either.

### transfer your program to fgba through uart
An usb to ttl cable may be needed to connect your computer and fgba.
To send data to fgba, please connect tx on the cable to gpio[8] on the fpga, and connect gnd on the cable to ground (which is the pin below gpio[9]) on the fpga.
Now sending data from the computer through serial may cause LED on fpga to flash.
LED[7:0] actually indicates the xor of all data received.

To transfer the program, please turn on SW[0] while pressing KEY[0] (which serves as the RESET key). Then fgba turns into a mode where he stores all data received to the Game Pak. Your program/data should be sent through serial port in little endian.

## Others
### putc
`putc` function could be used for debugging. To use `putc`, please connect rx on your serial cable to gpio[9] on the fpga, as well as gnd on the cable to ground on fpga. Then you would be able to run `/tests/uart2pc`, which sends a `Hello, World` through serial to your computer.

