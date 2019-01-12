# fgba

**这是我们数字电路课程的实验作业，鉴于课程已经结束，开发已经中止**  

fgba 是一个在 fpga 开发板上实现 Gameboy Advance (gba) 模拟器的项目。

## 实验环境
- Intel cyclone V, 5CSXFC6D6F31C6
- Quartus v17.1 lite

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
