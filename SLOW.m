% -----------------------------
% Function: Provides the derivatives of the SLOW ODEs
% ------------
% Input:
% - x           vector of states 
% - v_0         scalar of rotor-effective wind speed
% - Parameter   struct of Parameters
% ------------
% Output:
% - x_dot       vector of derivatives 
% ----------------------------------
function [x_dot] = SLOW(x,v_0,Parameter)

% internal parameters to make code easier to read
J           = Parameter.Turbine.J;
x_0T        = Parameter.Turbine.x_0T;
k_eT        = Parameter.Turbine.k_eT;
m_eT        = Parameter.Turbine.m_eT;
c_eT        = Parameter.Turbine.c_eT;
r_GB        = Parameter.Turbine.r_GB;
k           = Parameter.VSC.k;

% renaming states
Omega       = x(1);
x_T         = x(2);
x_T_dot    	= x(3);

% Aerodynamics
switch Parameter.AeroMode 
    case 'AD'
        [M_a,F_a]   = Aerodynamics_AD(x,v_0,Parameter);
    case 'BEM'
        [M_a,F_a]   = Aerodynamics_BEM(x,v_0,Parameter);         
    otherwise
        error('Aerodynamics Module %s not defined',Parameter.AeroMode)
end

% Torque Controller
Omega_G     = Omega*r_GB;   % Equation (3.7a) in [4]
M_G         = k*Omega_G^2;  % baseline torque controller in region 2

% derivatives from Equation (3.3) in [4]
Omega_dot   = (M_a-M_G*r_GB)/J;     
x_T_ddot    = (F_a-c_eT*x_T_dot-k_eT*(x_T-x_0T))/m_eT;

% renaming output
x_dot(1)    = Omega_dot;
x_dot(2)    = x_T_dot;
x_dot(3)    = x_T_ddot;

end

