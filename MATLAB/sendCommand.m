function sendCommand(~, ~)
global s hInput1 hInput2 originalAngle1 originalAngle2

    % Get values from input fields as strings but convert to numbers
    % Input1 = x, Input2 = y
    input1 = str2num(get(hInput1, 'String'));
    input2 = str2num(get(hInput2, 'String'));
    set(hInput1, 'String', '')
    set(hInput2, 'String', '')
    % validate input
    if numel(input1) ~= 1
        return; % input field must contain one value
    end
    if numel(input2) ~= 1
        return; % input field must contain one value
    end

    % Calculate angle
    IK = InverseKinetic(input1, input2);
    % IK = InverseKinetic(0, 156);
    TargetAngle1 = IK(1);
    TargetAngle2 = IK(2);

    DeltaAngle1 = TargetAngle1 - originalAngle1;
    DeltaAngle2 = TargetAngle2 - originalAngle2;

    % format command values as a string, e.g. C40.0,3.5;
    cmdStr = sprintf("C%.2f,%.2f;", DeltaAngle1, DeltaAngle2);
    
    % Send command string to microcontroller
    write(s, cmdStr, "string");
    display("Number of sending: " + s.UserData.Count + char(10) + 'Outcome to Arduino: ' + cmdStr);
    s.UserData.Count = s.UserData.Count + 1;
end







