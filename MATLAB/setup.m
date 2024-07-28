function setup(~)
close all
clear all
% declare global variables
%   s           serial port communication
%   hInput1     input widget 1
%   hInput1     input widget 2
%   hPlot       plot widget
%   hFig        figure widget
%   hTimer      continuous timer
%   c           command type
%   y1          data stream series 1
%   y2          data stream series 2
global s hInput1 hInput2 hPlot hFig hAngleinput1 hAngleinput2 hTimer c y1 y2 originalAngle1 originalAngle2 currentAngle1 currentAngle2 hArm1 hArm2 hPath hPlotError standardLine listglobalTargetX listglobalTargetY hlistglobalTarget ReportError1 ReportError2 ReportTime
%% Set up

ReportError1 = [];
ReportError2 = [];
ReportTime = [];

% Create serial port object
currentCOM = "COM5";
s = serialport(currentCOM, 9600);
configureTerminator(s,"CR/LF");
s.UserData = struct("Data",[],"Count",1);
configureCallback(s, "off");
s
% Create GUI
hFig = figure('Name', 'Team Six');

% Create input field for sending angle
hAngleinput1 = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', [0.7, 0.05, 0.1, 0.05]);
hAngleinput2 = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', [0.8, 0.05, 0.1, 0.05]);
hAnglesend = uicontrol('Units', 'normalized', 'Style', 'pushbutton', 'String', 'Send angle', 'Position', [0.7, 0.1, 0.1, 0.05], 'Callback', @sendAngle);
hAngle_0_0 = uicontrol('Units', 'normalized', 'Style', 'pushbutton', 'String', '¯\_(ツ)_/¯', 'Position', [0.8, 0.1, 0.1, 0.05], 'Callback', @sendAngle_0_0);

% Create homing button
hHoming = uicontrol('Units', 'normalized', 'Style', 'pushbutton', 'String', 'Homing', 'Position', [0.7, 0.15, 0.1, 0.05], 'Callback', @Homing);

% 
% % Create input field for sending commands to microcontroller
% hInput1 = uicontrol('Style', 'edit', 'Position', [20, 20, 100, 25]);
% hInput2 = uicontrol('Style', 'edit', 'Position', [120, 20, 100, 25]);
% 
% % Create button for sending commands
% hSend = uicontrol('Style', 'pushbutton', 'String', 'Send', 'Position', [20, 50, 100, 25], 'Callback', @sendCommand);

% Create plot area
hPlot = axes('Position', [0.1, 0.3, 0.8, 0.65]);
hold on
viscircles(hPlot, [0,0], 156, Color = 'black', LineWidth = 1);
hPath = plot(hPlot, 0, 0, 'black-');
hArm1 = plot(hPlot, [0, 78],[0, 0], 'blue-');
hArm2 = plot(hPlot, [78, 156],[0, 0], 'red-');
axis(hPlot, 'equal', [-300, 300, -180, 180]);
% set(hPlot, 'XLim', [-160, 160], 'XLabel', xlabel('X'), 'YLabel', ylabel('Y'));

% Add working square
line([0, 156, 156, 0, 0], [0, 0, 156, 156, 0], 'Color', 'g', 'LineStyle', '--', 'LineWidth', 1)

% Create a Plot for Error
hPlotError = axes('Position', [0.3, 0.05, 0.35, 0.15]);
hold on
set(hPlotError, 'XLim', [-1000, 1000], 'YLim', [-5, 5], 'YLabel', ylabel('Error'));
standardLine = plot(hPlotError, [-1000, 1000], [0, 0], "black");
% Set up variables for real-time plotting
c = [];
y1 = repmat(156,[1,25]);
y2 = repmat(0,[1,25]);
t0 = now;
% Pathway
listglobalTargetX = [156];
listglobalTargetY = [0];
hlistglobalTarget = plot(hPlot, 0, 0, 'black.');

currentAngle1 = 0;
currentAngle2 = 0;
originalAngle1 = 0;
originalAngle2 = 0;

% Set up timer for continuously receiving data from microcontroller
% hTimer = timer('ExecutionMode', 'fixedRate', 'Period', 0.05, 'TimerFcn', @readDataTimer);
% warning("off","serialport:serialport:ReadlineWarning");
% start(hTimer);
configureCallback(s, "terminator", @readDataTimer);
hFig.CloseRequestFcn = @closeGUI;


end

function Homing(~, ~)
global s 
write(s, 1, "int8");
end