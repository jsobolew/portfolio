clear all;
close all;

%% SIMULATION SETTING
% beam angle
beam_angle = pi/10;
%timestep
timestep = 0.5e-3;

%time in [s]
time = 2;

% number of simulation points
points = time/timestep;

%time vector
time_vector = timestep:timestep:time;

% object distance from radar in [m]
distance_from_radar.x = 99;
distance_from_radar.y = 100;

% radar position is always (0,0) <=> ISAR
radar.x = 0;
radar.y = 0;

%% OBJECT
% OBJECT SHAPE
%   object shape is determined by giving (x,y) coorinates on a plane

object.x = [-6 0 0 0 6];
object.y = [0 0 5 -5 0];

% object.x = 0;
% object.y = 0;

% object.x = x;
% object.y = y;

figure(1)
plot(object.x,object.y,'or','MarkerFaceColor','#0072BD')
title('object shape')
xlabel('x axis [m]')
ylabel('y axis [m]')
axis equal
grid on;


% OBJECT VELOCITY
%   (velocity [m/s], angle[rad])
% 
%   Radial velocity is defined as being positive when a target is moving away from
%   the radar, and as negative when it is moving towards the radar.
%

velocity.speed = 100;
velocity.angle = -pi/2;

%radial_velocity = velocity.speed*cos(velocity.angle);


figure(2)
plot(0,0,'square','MarkerFaceColor','#0072BD')
hold on;
grid on;
title('scene')
xlabel('x axis [m]')
ylabel('y axis [m]')
axis equal
plot(object.x+distance_from_radar.x,object.y+distance_from_radar.y,'or','MarkerFaceColor','#0072BD')
%annotation('textarrow',[distance_from_radar.x, distance_from_radar.x + 5*cos(velocity.angle)],[distance_from_radar.y, distance_from_radar.y + 5*cos(velocity.angle)],'String',' Growth ','FontSize',13,'Linewidth',2)
line([distance_from_radar.x, distance_from_radar.x + 5*cos(velocity.angle)],[distance_from_radar.y, distance_from_radar.y + 5*sin(velocity.angle)],'color','green','linewidth',5)
line([0, distance_from_radar.x],[0, distance_from_radar.x*tan(beam_angle)],'color','black','linewidth',3)
line([0, distance_from_radar.x],[0, -distance_from_radar.x*tan(beam_angle)],'color','black','linewidth',3)
hold off;

%% POINTS GENERATION
%allocation

x = zeros(length(object.x),points);
y = zeros(length(object.x),points);

dvx = velocity.speed*cos(velocity.angle);
dvy = velocity.speed*sin(velocity.angle);

dx = velocity.speed*cos(velocity.angle)*timestep;
dy = velocity.speed*sin(velocity.angle)*timestep;
for j = 1:length(object.x)
    x(j,1) = object.x(j)+distance_from_radar.x;
    y(j,1) = object.y(j)+distance_from_radar.y;
end

% allocation
distance_from_radar = zeros(length(object.x),points);
radial_speed = zeros(length(object.x),points-1);
for i = 2:points
    for j = 1:length(object.x)
        x(j,i) = x(j,i-1) + dx;
        y(j,i) = y(j,i-1) + dy;
    end
end

for i = 1:points
    for j = 1:length(object.x)
        angle_to_radar(j,i) = atan(y(j,i)/x(j,i));
%         if abs(angle_to_radar) < beam_angle
             distance_from_radar(j,i) = sqrt((radar.x + x(j,i))^2 + (radar.y + y(j,i))^2);
%         else
%             distance_from_radar(j,i) = 0;
%         end
    end
end

for j = 1:length(object.x)
    radial_speed(j,:) = diff(distance_from_radar(j,:));
end

for j = 1:length(object.x)
    radial_speed(j,length(distance_from_radar)) = radial_speed(j,length(distance_from_radar)-1);
end

for i = 1:points
    for j = 1:length(object.x)
        if abs(angle_to_radar(j,i)) > beam_angle
            distance_from_radar(j,i) = 0;
            radial_speed(j,i) = 0;
        end
    end
end


%% RESULTS VISUALIZATION
figure(3)
hold on;
for i = 1:size(distance_from_radar,1)
    plot(x(i,:),y(i,:))
end
title('points migration path in time')
xlabel('x distance [m]')
ylabel('y distance [m]')
hold off;

figure(4)
hold on;
for i = 1:size(distance_from_radar,1)
    plot(time_vector,distance_from_radar(i,:))
end
title('points distance from radar')
xlabel('time [s]')
ylabel('distance [m]')
hold off;

figure(5)
hold on;
for i = 1:size(distance_from_radar,1)
    plot(time_vector,radial_speed(i,:))
end
title('radial velocity in time')
xlabel('time [s]')
ylabel('velocity [m/s]')
hold off;

