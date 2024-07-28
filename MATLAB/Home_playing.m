result = [];
m = randi([0, 156], 1, 10);
n = randi([0, 156], 1, 10);
for i = 1:10
    j=i;
    % for j = 1:10
    % fk = Forward_kinematics(i, j)*[0;0;0;1];
    % iv = Inverse_kinematics(fk(1), fk(2));
    if ((m(i)^2 + n(j)^2) < 24336)
    iv = Inverse_kinematics(m(i), n(j));
    df = Differential_Inverse_Kinametic(m(i), n(j));

% Start the timer
tic
% Call your function here
Differential_Inverse_Kinametic(m(i), n(i))

% Stop the timer and display the elapsed time
elapsedTime2 = toc;

% Start the timer
tic
% Call your function here
Inverse_kinematics(m(i), n(j));

% Stop the timer and display the elapsed time
elapsedTime1 = toc;

    % result = [result; i, j, "-", round(fk(1),1), round(fk(2),1), "-", round(iv(1),1), round(iv(2),1)];
    result = [result; m(i), n(j), "-", round(iv(1),6), round(iv(2),6), "-", round(df(1),6), round(df(2),6), elapsedTime1, elapsedTime2];
    % end
    end
end
result
% 
% 
% 
% % Start the timer
% tic
% % Call your function here
% Differential_Inverse_Kinametic(m(i), n(i))
% 
% % Stop the timer and display the elapsed time
% elapsedTime = toc;
% disp(['Differ ', num2str(elapsedTime), ' seconds']);
% 
% % Start the timer
% tic
% % Call your function here
% Inverse_kinematics(m(i), n(j));
% 
% % Stop the timer and display the elapsed time
% elapsedTime = toc;
% disp(['Ana ', num2str(elapsedTime), ' seconds']);
% 
% 
