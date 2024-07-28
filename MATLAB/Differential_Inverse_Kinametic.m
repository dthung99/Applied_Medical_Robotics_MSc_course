function res = Differential_Inverse_Kinametic(px,py)
damping_factor = 1;
clamping_rate = 20;
% Arm length
t1 = 0;
t2 = 90;
% Calculate angle t2 t1
% Get the position of end effectors corresponding to joints' values
position = ForwardKinetic(t1, t2);
current_x = position(1,4);
current_y = position(2,4);
% Calculate the different between current position and target one
dx = px - current_x;
dy = py - current_y;

% Loop to get new joint value to get closer to target
while (abs(dx)>0.001) || (abs(dy)>0.001)
    % Calculate jacobian and pseudo inverse (with damping factor k = 1)
    jab = jacobian_short(t1, t2);
    [dx, dy] = target_Clamping(dx, dy, clamping_rate);
    new_joints = jab'/(jab*jab'+ damping_factor^2)*[dx; dy] * 180/pi;
    % Update new joint
    t1 = t1 + new_joints(1);
    t2 = t2 + new_joints(2);
    % Update new position
    position = ForwardKinetic(t1, t2);
    current_x = position(1,4);
    current_y = position(2,4);
    % Get the new differences
    dx = px - current_x;
    dy = py - current_y;
end

res = [t1, t2];
end

function [res1, res2] = target_Clamping(dx, dy ,d)
if norm(dx, dy) < d
    res1 = dx;
    res2 = dy;
else
    res1 = dx/norm(dx, dy)*d;
    res2 = dy/norm(dx, dy)*d;
end
end

function res = jacobian_short(t1, t2)
r1 = 78;
r2 = 78;
t1 = deg2rad(t1);
t2 = deg2rad(t2);
res = [- r1*sin(t1) - r2*sin(t1+t2), - r2*sin(t1+t2);
    + r1*cos(t1) + r2*cos(t1+t2), r2*cos(t1+t2)];
end

