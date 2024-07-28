function sendAngle(~, ~)
global hAngleinput1 hAngleinput2 originalAngle1 originalAngle2 currentAngle1 currentAngle2 hInput1 hInput2 y1 y2 hPlot hArm1 hArm2 globalTargetx globalTargety listglobalTargetX listglobalTargetY circle_listglobalTargetX circle_listglobalTargetY

%% Get value and set up current angle
originalAngle1 = str2num(get(hAngleinput1, 'String'));
originalAngle2 = str2num(get(hAngleinput2, 'String'));

globalTargetx = 156;
globalTargety = 0;
listglobalTargetX = [156];
listglobalTargetY = [0];
circle_listglobalTargetX = [];
circle_listglobalTargetY = [];

if numel(originalAngle1) ~= 1
    return; % input field must contain one value
end
if numel(originalAngle2) ~= 1
    return; % input field must contain one value
end
set(hAngleinput1, 'String', '')
set(hAngleinput2, 'String', '')
currentAngle1 = originalAngle1;
currentAngle2 = originalAngle2;

% Original position
FK = ForwardKinetic(originalAngle1, originalAngle2)*[0;0;0;1];
mFK = middleFK(originalAngle1)*[0;0;0;1];
% y1 is x, y2 is y. 25 is lenght of black line
y1 = repmat(FK(1),[1,25]);
y2 = repmat(FK(2),[1,25]);

% Plot the arms
set(hArm1, 'XData', [0, mFK(1)], 'YData', [0, mFK(2)])
set(hArm2, 'XData', [mFK(1), FK(1)], 'YData', [mFK(2), FK(2)])

%% Create GUI for sending coordinate
% Create input field for sending commands to microcontroller
hInput1 = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', [0.05, 0.05, 0.1, 0.05]);
hInput2 = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', [0.15, 0.05, 0.1, 0.05]);
% Create button for sending commands
hSend = uicontrol('Units', 'normalized', 'Style', 'pushbutton', 'String', 'Send', 'Position', [0.1, 0.1, 0.1, 0.05], 'Callback', @sendCommand);
% Create an UI to get coordinate
set(hPlot, 'ButtonDownFcn', @detectCoordinate);

% disp(originalAngle1);
% disp(originalAngle2);
% disp(currentAngle1);
% disp(currentAngle2);

end

