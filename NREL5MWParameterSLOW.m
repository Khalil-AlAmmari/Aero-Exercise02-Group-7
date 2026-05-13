% -----------------------------
% Function: provides parameter for NREL5MW SLOW wind turbine model based on 
% [1] and [4]
% ------------
% Input:
% none
% ------------
% Output:
% - Parameter   struct of Parameters
% ----------------------------------
function Parameter = NREL5MWParameterSLOW

%% General          
Parameter.General.rho               = 1.225;         	% [kg/m^3]  air density

%% Turbine
Parameter.Turbine.r_GB             	= 97;               % [-]       gearbox ratio (in [4], i_GB=1/r_GB is used)
Parameter.Turbine.R              	= 126/2;            % [m]       Rotor radius

% drive-train dynamics, Equation (3.4) in [4]
Parameter.Turbine.J                	= 44516521;         % [kgm^2] sum of moments of inertia about the low-speed shaft

% fore-aft tower dynamics, Equation (3.5) in [4]  
Parameter.Turbine.m_eT          	= 429918.4;         % [kg]      tower equivalent modal mass
Parameter.Turbine.k_eT            	= 1814852;          % [kg/s^2]  tower equivalent bending stiffness 
Parameter.Turbine.c_eT            	= 7066.488;         % [kg/s]	tower equivalent structual damping
Parameter.Turbine.x_0T           	= -0.0138;          % [m]       tower top position without wind from steady state simulations using FAST

% Rotor geometry
Parameter.Turbine.ShftTilt          = deg2rad(-5);      % [rad]     Rotor shaft tilt angle

end