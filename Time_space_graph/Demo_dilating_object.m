% This code set demos the minkowski sum
% requires 'minkowskiSum' add-on
% this example will dialate an object(object 1) by the vehicle
% width(object 2). But it should work with any polygons.


%Generate the vehicle width
vehicle_param.w_vehicle = 69.3/(12*3.281); % the width of the vehicle_param, [m] from 63.9 inches
% create an object representing the vehicle width (a thin rectangle)
object_2 = [0 0;0 vehicle_param.w_vehicle;0.01 vehicle_param.w_vehicle;0.01,0];

% generate the unit square
object_1 = [0 0;0 1; 1 1; 1 0]
%translate to have center at orgin.
object_1 = object_1 +[-.5 -.5];
%rotate object
theta = deg2rad(30);
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
object_1 = (R * object_1')';

%Center the vehicle width object
object_2 = object_2+[0,-vehicle_param.w_vehicle/2];

%prefrom minkowski sum to generate dialated objects
test = minkowskiSum(object_1,object_2)

%plotting both object, using polyshape to make it easier
plot(test);
hold on;
axis equal;
object2 = polyshape(object_2);
object1 = polyshape(object_1);
plot(object2);
plot(object1);
