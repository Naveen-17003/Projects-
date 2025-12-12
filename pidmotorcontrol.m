
clear; clc; close all;

J = 0.01;   % Rotor inertia (kg.m^2)
b = 0.1;    % Damping coefficient
K = 0.01;   % Motor constant
R = 1;      % Armature resistance
L = 0.5;    % Armature inductance

s = tf('s');


motor_tf = K / ((J*s + b)*(L*s + R) + K^2);

disp('DC Motor Transfer Function:');
motor_tf

%% Open Loop Response
figure;
step(motor_tf);
title('Open Loop DC Motor Speed Response');
grid on;

%% P Controller
Kp = 300;
P_controller = Kp;
sys_P = feedback(P_controller * motor_tf, 1);

%% PI Controller
Ki = 200;
PI_controller = Kp + Ki/s;
sys_PI = feedback(PI_controller * motor_tf, 1);

%% PID Controller
Kd = 10;
PID_controller = Kp + Ki/s + Kd*s;
sys_PID = feedback(PID_controller * motor_tf, 1);

%% Step Responses Comparison
figure;
step(sys_P, sys_PI, sys_PID, 2);
legend('P Control', 'PI Control', 'PID Control');
title('Speed Control of DC Motor');
xlabel('Time (seconds)');
ylabel('Speed');
grid on;

%% Performance Analysis
info_P   = stepinfo(sys_P);
info_PI  = stepinfo(sys_PI);
info_PID = stepinfo(sys_PID);

disp('--- Performance Comparison ---');
disp('P Controller:');   disp(info_P);
disp('PI Controller:');  disp(info_PI);
disp('PID Controller:'); disp(info_PID);
