function detectCoordinate(src, event)
global s hInput1 hInput2 originalAngle1 originalAngle2 listglobalTargetX listglobalTargetY

% Get the current mouse position
mousePosition = get(src, 'CurrentPoint');
x = mousePosition(1,1);
y = mousePosition(1,2);


listglobalTargetX = [listglobalTargetX, x];
listglobalTargetY = [listglobalTargetY, y];


% % Display the mouse position
% % disp(['Mouse position: x = ', num2str(x), ', y = ', num2str(y)]);
% 
% % hInput1.String = num2str(x);
% % hInput2.String = num2str(y);
% 
% % NEW VERSION
% % Calculate angle
% input1 = x;
% input2 = y;
% IK = InverseKinetic(input1, input2);
% % IK = InverseKinetic(0, 156);
% TargetAngle1 = IK(1);
% TargetAngle2 = IK(2);
% 
% DeltaAngle1 = TargetAngle1 - originalAngle1;
% DeltaAngle2 = TargetAngle2 - originalAngle2;
% 
% % format command values as a string, e.g. C40.0,3.5;
% cmdStr = sprintf("C%.2f,%.2f;", DeltaAngle1, DeltaAngle2);
% 
% % Send command string to microcontroller
% write(s, cmdStr, "string");
% display("Number of sending: " + s.UserData.Count + char(10) + 'Outcome to Arduino: ' + cmdStr);
% s.UserData.Count = s.UserData.Count + 1;

end