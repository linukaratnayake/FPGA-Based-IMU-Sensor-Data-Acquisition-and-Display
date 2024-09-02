# FPGA Based IMU Sensor Data Acquisition and Display

## Project Target

<ul>
 <li>Implement I2C protocol on an FPGA.</li>
 <li>Read data from an Inertial Measurement Unit (IMU) sensor using I2C, in a given sampling frequency.</li>
 <li>Store data in an internal buffer (memory).</li>
 <li>Send data to a Raspberry Pi using UART protocol (implemented before).</li>
 <li>Graphically display the sensor readings in the Raspberry Pi.</li>
</ul>

## Current Progress

### Completed Tasks
<ul>
 <li>Created a project in Vivado for Zybo FPGA board.</li>
 <li>Partially implemented I2C transmitter (data sending portion of the protocol) in Verilog.</li>
</ul>

### Currently Doing
<ul>
 <li>Fine tuning data sending using SDA, and SCL lines, acting as a transmitter.</li>
</ul>

The waveform for sending two values `0x6B` and `0x68` as an example is shown below.

![waveform](https://github.com/user-attachments/assets/babad7a7-1525-4a01-95a4-7615e0828469)
