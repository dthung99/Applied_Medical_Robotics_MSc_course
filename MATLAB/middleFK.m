function res = middleFK(t)
    t = deg2rad(t);
    res = [cos(t), -sin(t), 0, 78*cos(t)
        sin(t), cos(t), 0, 78*sin(t)
        0, 0, 1, 0
        0, 0, 0, 1];
end
