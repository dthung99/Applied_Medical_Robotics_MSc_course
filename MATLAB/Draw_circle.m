function Draw_circle(radius)
global originalAngle1 originalAngle2 currentAngle1 currentAngle2 circle_listglobalTargetX circle_listglobalTargetY listglobalTargetX listglobalTargetY

FK = ForwardKinetic(currentAngle1, currentAngle2)*[0;0;0;1];
center = [radius; 0] + FK(1:2,:);

% Generate an array of angles from 0 to 2*pi
theta = linspace(-pi, pi, 32);

% Calculate the x and y coordinates of points on the circle
x = center(1) + radius * cos(theta);
y = center(2) + radius * sin(theta);

% Update listglobalTarget
circle_listglobalTargetX = x;
circle_listglobalTargetY = y;

listglobalTargetX = [listglobalTargetX, FK(1)];
listglobalTargetY = [listglobalTargetY, FK(2)];

end