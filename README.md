# MIPS40 CPUDynamicPipe



## 项目背景 :bulb: 

- :happy: 本项目是计算机系统课程的第二个实验作业；
- :zap: 在原有的经典五段流水线的基础上添加了 CP0 与两个硬件中断；
- :open_mouth: 结合了龙芯（强烈感谢）出品的《CPU设计实战》一书中的实际开发经验。



## 开发环境

### 硬件 :computer:

- 型号 ：Dell Inspiration 7590；
- CPU ：Intel Core i7-9750H；
- 内存 ：SKHylix 16GB 2666MHz；
- 开发板 ：Digilent Xilinx Nexys4 DDR 。



### 软件 :floppy_disk:

- 系统 ：Windows 11 Home Basic 64-bit 21H1；
- 版本控制 ：Git 2.32.0 & Github Desktop 2.9.5；
- EDA 工具 ： Vivado ML Editions 2021.1；
- Java ：Oracle JDK 11.0.3；
- 程序模拟 ：Mars 4.5；
- 电路绘制 ：Visio 2019 。



## 特点与支持的指令 :dart: 

- 设计方案选取了 MIPS32 Release 5 中的下列 40 条指令实现；
- 采取了延时槽机制；
- 采用旁路技术解决指令间数据相关冲突；
- 在 ID 段完成跳转地址与成立条件的计算；
- 选择实现 CP0 中与中断相关的相关寄存器，并对各个域进行分别管理;

|      |      | 支持的指令列表 |       |      |
| :--: | :--: | :------------: | :---: | :--: |
| ADDU | ADD  |     ADDIU      | ADDI  | SUBU |
| SUB  | SLTU |      SLT       | SLTIU | SLTI |
| AND  | ANDI |       OR       |  ORI  | XOR  |
| XORI | NOR  |      SLL       | SLLV  | SRL  |
| SRLV | SRA  |      SRAV      |  LW   |  SW  |
| BEQ  | BNE  |       J        |  JAL  |  JR  |
| LUI  | MULT |     MULTU      | MFHI  | MFLO |
| MTHI | MTLO |      MTC0      | MFC0  | ERET |



## 实现细节 :tada:

- `100MHz` 全局时钟通过 `MMCM Clock IP Core` 进行分频以及相位转换，在具体下板实现中手动降频至 `100Hz` 以便更明显观察现象。

- 使用上升沿更新 `PC` 流水寄存器，下降沿向其他所有寄存器写入数据。

  > 采取该设计的原因是根据 xlinix 的文档，`BRAM`需要遵守访存时，`ADDRA` 端口需要在时钟上升沿前准备好访存地址，然后时钟上升沿 `BRAM`将在时钟为高电平的时间内给出访存数据，而由于给出的读写信号，访存地址可能由于网线的路径延迟不同，上升沿可能导致数据不到位。
  >
  > ![](https://raw.githubusercontent.com/xw1216/ImageHosting/main/img/doc.png)
  >
  > 还有一个重要原因是自己怎么测都发现上升沿同时写所有的寄存器无论如何都会出现数据不一致或流水线无法启动的现象。

- 实现了两个外部中断，当响应 `pause` 中断时，处理器将 `PC` 停留在约定的 `0x04000004` 的空指令上，使处理器进入核心态，直到下一个中断到来；当响应 `resume` 中断时，处理器将 `PC` 转移至 `pause` 中断前停留的位置继续执行程序，并退出核心态。实际上这两个中断是设计来专门配合使用的。

- 当 `LW`指令、`MFC0` 指令与后续指令存在数据相关时，必须使流水线阻塞，分别等待 `MEM` 与 `WB` 阶段读回数据再通过前递旁路送回才能完成数据相关的处理。此外当 `MTC0` 没有完全执行完毕时，可能存在外部中断信号异步进入的情况，所以该情况极难通过硬件避免，采用软件约束。



## 实现效果 :mag:

![](https://raw.githubusercontent.com/xw1216/ImageHosting/main/img/%E6%95%88%E6%9E%9C.jpg)



## 项目总结 :yum:

- 本次项目说是仅仅基于第一个实验中的流水线 CPU 添加功能，可是实际上需要增加的传递信号多了很多，而且需要从 `ID` 段层层传递到 `WB` 段且又反馈给 `ID` 控制器用以发出正确的清空流水线等信号。
- 课本涉及的动态与静态流水线对于实验设计根本没有任何用，或许加入除法之后才能体现出来吧。
- 尚且没有加入分支预测或者完整的软件异常与硬件中断，有点遗憾。



------

Wayne Bear (c) 2021  

