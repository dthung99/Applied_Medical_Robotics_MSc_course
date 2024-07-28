function res = ForwardKinetic(t1, t2)
    t1 = deg2rad(t1);
    t2 = deg2rad(t2);
    r1 = 78;
    r2 = 78;
    res = [cos(t1 + t2), -sin(t1 + t2), 0, r2*cos(t1 + t2) + r1*cos(t1)
        sin(t1 + t2),  cos(t1 + t2), 0, r2*sin(t1 + t2) + r1*sin(t1)
        0, 0, 1, 0
        0, 0, 0, 1];
end
