% Specify the serial port name and other configuration parameters
port = 'COM5';  % Replace 'COM1' with the appropriate port name for your system
baudrate = 9600;  % Specify the baud rate


serialportlist("all")
serialportlist("available")

% Create a serial object
s = serialport('COM5', 9600);
% Close the serial port
delete(s);
clear s;
% Open the serial port

% Check if the serial port is open
if strcmp(s.Status, 'open')
    disp('Serial port opened successfully.');
else
    disp('Failed to open the serial port.');
end

% ... Perform your desired serial communication here ...
configureTerminator(s,"CR/LF");
s.NumBytesAvailable;
s.BytesAvailableFcn = @myCallbackFunction;
configureCallback(s,"terminator",@myCallbackFunction)
configureCallback(s,"off")
a = 10;
read(s, a, "char");
disp(a);
serialbreak(device,10);

readline


%%New code to add
% Create input field for sending angle
hAngleinput1 = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', [0.7, 0.05, 0.1, 0.05]);
hAngleinput2 = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', [0.8, 0.05, 0.1, 0.05]);
hAnglesend = uicontrol('Units', 'normalized', 'Style', 'pushbutton', 'String', 'Send angle', 'Position', [0.7, 0.1, 0.2, 0.05], 'Callback', @sendAngle);

% Create input field for sending commands to microcontroller
hInput1 = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', [0.05, 0.05, 0.1, 0.05]);
hInput2 = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', [0.15, 0.05, 0.1, 0.05]);
% Create button for sending commands
hSend = uicontrol('Units', 'normalized', 'Style', 'pushbutton', 'String', 'Send', 'Position', [0.1, 0.1, 0.1, 0.05], 'Callback', @sendCommand);

set(hPlot, 'ButtonDownFcn', @detectCoordinate);



hPlotError = axes('Position', [0.3, 0.05, 0.35, 0.15]);
set(hPlotError, 'YLim', [-5, 5], 'YLabel', ylabel('Error'));
hold on
standardLine = plot(hPlotError, [-1000, 1000], [0, 0], "black");

set(hPlotError, 'XLim', [-500,500]);
set(standardLine, "XData", [-500,500]);

plot(hPlotError, 1000, 0, "bo", 'MarkerSize', 3)

figure
hold on
plot([0,100],[0,0],"k")
plot(ReportTime/1000-7.99, ReportError1);
xlabel('Time (second)');
ylabel('Error (Degrees)');
title('Motor 1 angle error');
xlim([0,3])
ylim([-5,inf])

figure
hold on
plot([0,100],[0,0],"k")
plot(ReportTime/1000-7.99, ReportError2);
xlabel('Time (second)');
ylabel('Error (Degrees)');
title('Motor 2 angle error');
xlim([0,3])
ylim([-5,inf])


