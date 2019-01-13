# fgba

**这是我们数字电路课程的实验作业，鉴于课程已经结束，开发已经中止**  

fgba 是一个在 fpga 开发板上实现 Gameboy Advance (gba) 模拟器的项目。
项目包括在开发板上实现一个 armv4t 的 CPU，实现 gba 设备的各种外设，并且把图像输出出到一个 640x480 的 VGA 屏幕的左上角上。

## 实验环境
- Intel cyclone V, 5CSXFC6D6F31C6
- Quartus v17.1 lite
- Verilog HDL

## 进度

<table>
  <tr>
    <th colspan="2">模块</th>
    <th>进度</th>
  </tr>
  <tr>
    <td rowspan="3"> CPU </td>
    <td> 寄存器/架构设计 </td>
    <td> 完成 </td>
  </tr>
  <tr>
    <td> ARM 指令集 </td>
    <td> 完成，除了软中断指令。 </td>
  </tr>
  <tr>
    <td> Thumb 指令集 </td>
    <td> 完成，除了软中断指令。似乎有bug，但是跑挺大的游戏没问题。</td>
  </tr>
  <tr>
    <td rowspan="7"> Memory </td>
    <td> ROM </td>
    <td> 完成，拷贝自 <a href="http://vba-m.com/"> http://vba-m.com/ </a></td>
  </tr>
  <tr>
    <td> Internal Working RAM </td>
    <td> 完成 </td>
  </tr>
  <tr>
    <td> External Working RAM </td>
    <td> 完成 </td>
  </tr>
  <tr>
    <td> Palette RAM </td>
    <td> 只实现了前半个 kb </td>
  </tr>
  <tr>
    <td> VRAM </td>
    <td> 完成 </td>
  </tr>
  <tr>
    <td> OAM </td>
    <td> 未开始 </td>
  </tr>
  <tr>
    <td> Game Pak </td>
    <td> 暂时用片内存储代替，只有140 kb。可以用 SDRAM 支持 32Mb 存储空间。</td>
  </tr>
  <tr>
    <td rowspan="9"> Image System </td>
    <td> mode 0 </td>
    <td> 未开始 </td>
  </tr>
  <tr>
    <td> mode 1 </td>
    <td> 未开始 </td>
  </tr>
  <tr>
    <td> mode 2 </td>
    <td> 未开始 </td>
  </tr>
  <tr>
    <td> mode 3 </td>
    <td> 完成 </td>
  </tr>
  <tr>
    <td> mode 4 </td>
    <td> 完成 </td>
  </tr>
  <tr>
    <td> mode 5 </td>
    <td> 未开始 </td>
  </tr>
  <tr>
    <td> Object </td>
    <td> 未开始 </td>
  </tr>
  <tr>
    <td> Window </td>
    <td> 未开始 </td>
  </tr>
  <tr>
    <td> Rotating/Scaling </td>
    <td> 未开始 </td>
  </tr>
  <tr>
    <td rowspan="5"> 外设 </td>
    <td> Sound </td>
    <td> 未开始 </td>
  </tr>
  <tr>
    <td> Timer </td>
    <td> 完成 </td>
  </tr>
  <tr>
    <td> DMA </td>
    <td> 未开始 </td>
  </tr>
  <tr>
    <td> Key Input </td>
    <td> 完成 </td>
  </tr>
  <tr>
    <td> Interrupt Control </td>
    <td> 未开始 </td>
  </tr>
  <tr>
    <td rowspan="1"> Communication </td>
    <td> 全部 </td>
    <td> 未开始 </td>
  </tr>
  
</table>

## 运行方法

### 编译
用 Quartus 打开 quartus_proj 文件夹，直接生成 sof 文件。如果你使用别的开发环境，应该不难把项目移植过去。

### 使用 uart 将程序传输到 fpga 上
请准备一个 usb 转 ttl 转接线插在电脑上，将转接线 tx 端与开发板 gpio_8 连接，gnd 与开发板接地，此时用串口调试工具向串口发送数据，LED_0 - LED_7 会闪烁，LED[7:0]指示了开发板接收到的数据的异或和。
为了将程序发送到开发板，按住 Reset(KEY[0])，拉高 SW[0]，进入接收模式。此时开发板会把接收到的数据按 32 位一个字存到 Game Pak 存储区。每个字应先发送低位的 byte，即小端方式。
传送完成后可以检查 LED 指示灯与发送内容每个字节的异或和是否相同，若不同，则传输一定出错了，可以选择再来一遍。
拉低 SW[0]，新的程序就开始在开发板上运行了。

## 其他
### putc
为了方便调试，fgba 实现了 putc 功能。请将 usb 转 ttl 转接线的 tx 端与开发板 gpio_9 相连，gnd 与开发板接地，运行 tests 目录下的 uart2pc 程序，就可以在电脑端通过串口接收到 Hello, World 了。
