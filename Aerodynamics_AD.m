% -----------------------------
% Function: Calculates aerodynamic torque and thrust based on the "actuator
% disk" approach from [4]
% ------------
% Input:
% - x           vector of states 
% - v_0         scalar of rotor-effective wind speed
% - Parameter   struct of Parameters
% ------------
% Output:
% - M_a         scalar of aerodynamic torque
% - F_a         scalar of aerodynamic thrust
% ----------------------------------
function [M_a,F_a] = Aerodynamics_AD(x,v_0,Parameter)

% internal parameters to make code easier to read
R           = Parameter.Turbine.R;
rho         = Parameter.General.rho;

% states
Omega       = x(1);
x_T_dot    	= x(3);

% Equation (3.10) in [4]
v_rel       = v_0-x_T_dot;
lambda      = Omega*R/v_rel;

% power and thrust coefficient
c_P         = interp1(Parameter.AD.lambda,Parameter.AD.c_P,lambda);
c_T         = interp1(Parameter.AD.lambda,Parameter.AD.c_T,lambda);

% Equation (3.9) in [4]
M_a         = 1/2*rho*pi*R^3*c_P/lambda*v_rel^2;
F_a         = 1/2*rho*pi*R^2*c_T*v_rel^2;

end