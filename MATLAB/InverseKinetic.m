function res = InverseKinetic(px,py)
% Arm length
r1 = 78;
r2 = 78;
% Calculate angle t2 t1
c2 = (px^2 + py^2 - r1^2 - r2^2)/(2*r1*r2);
s2 = sqrt(1 - c2^2);
t2 = atan2(s2,c2);
t1 = atan2(py,px)-atan2(r2*sin(t2),r1+r2*cos(t2));
% Return
res = [rad2deg(t1),rad2deg(t2)];
end