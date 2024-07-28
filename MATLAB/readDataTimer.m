function readDataTimer(~, ~)
global s hPlot c y1 y2 originalAngle1 originalAngle2 currentAngle1 currentAngle2 hArm1 hArm2 hPath hPlotError standardLine listglobalTargetX listglobalTargetY hInput1 hInput2 hlistglobalTarget circle_listglobalTargetX circle_listglobalTargetY ReportError1 ReportError2 ReportTime

    % Read the ASCII data from the serialport object.
    % try
    % catch
    %     return
    % end

    dataStr = readline(s);
    % disp(dataStr);
    % if isempty(dataStr)
    %     return;
    % end
    % if dataStr == ""
    %     return;
    % end
    % Parse data values from string and add accumulate into arrays
    % e.g. Arduino sending 2 series: c1,100
    data = sscanf(dataStr, "%c%d:%f-%f-%f-%f-%f-%f-%f-%f-%f-%f-%f");
    % c = [c, data(1)];
    % Get Angle
    currentAngle1 = originalAngle1 + data(3);
    currentAngle2 = originalAngle2 + data(4);
    % ForwarKinetic
    FK = ForwardKinetic(currentAngle1, currentAngle2)*[0;0;0;1];
    mFK = middleFK(currentAngle1)*[0;0;0;1];
    % y1 is x, y2 is y
    % y1(1) = [];
    % y2(1) = [];
    y1 = [y1, FK(1)]; 
    y2 = [y2, FK(2)];

    % real-time plotting, e.g. 2 series (y1, y2)
    set(hPath, 'XData', y1, 'YData', y2);
    set(hArm1, 'XData', [0, mFK(1)], 'YData', [0, mFK(2)]);
    set(hArm2, 'XData', [mFK(1), FK(1)], 'YData', [mFK(2), FK(2)]);
    set(hlistglobalTarget, 'XData', listglobalTargetX, 'YData', listglobalTargetY);
    % New movement command
    if (((abs(FK(1) - listglobalTargetX(1))) < 3) & ((abs(FK(2) - listglobalTargetY(1))) < 3) & (length(listglobalTargetX)>1))
    % if ((data(11) < 1) & (data(12) < 1) & (length(listglobalTargetX)>1))
        listglobalTargetX(1) = [];
        listglobalTargetY(1) = [];

        set(hInput1, 'String', num2str(listglobalTargetX(1)));
        set(hInput2, 'String', num2str(listglobalTargetY(1)));

        sendCommand();
        if length(circle_listglobalTargetX>0)
            listglobalTargetX = [listglobalTargetX, circle_listglobalTargetX(1)];
            listglobalTargetY = [listglobalTargetY, circle_listglobalTargetY(1)];
            circle_listglobalTargetX(1) = [];
            circle_listglobalTargetY(1) = [];
        end
    end

    % plotting Error
    % set(hPlotError, 'XLim', [data(7) - 500, data(7) + 500]);
    % set(standardLine, "XData", [data(7) - 500, data(7) + 500]);
    % plot(hPlotError, data(7), data(5), "bo", 'MarkerSize', 3);
    % plot(hPlotError, data(7), data(6), "ro", 'MarkerSize', 3);
    % disp(data(5) + " " + data(6) + " " + data(7) + " " + data(8) + " " + data(9) + " " + data(10) + " " + data(11) + " " + data(12));

    % ReportError1 = [ReportError1, data(5)];
    % ReportError2 = [ReportError2, data(6)];
    % ReportTime = [ReportTime, data(7)];    

    % disp(data(11) + " " + data(12));
    % disp(data(8)); %samplingtime
    % disp(listglobalTargetX);
    % disp(listglobalTargetY);
    % disp(dataStr);

end


