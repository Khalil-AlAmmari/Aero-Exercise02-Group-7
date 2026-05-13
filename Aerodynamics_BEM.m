% -----------------------------
% Function: Calculates aerodynamic torque and thrust based on the Blade
% Element Momentum Theory
% ------------
% Input:
% - x           vector of states [Omega, x_T, x_T_dot]
% - v_0         scalar of rotor-effective wind speed
% - Parameter   struct of Parameters
% ------------
% Output:
% - M_a         scalar of aerodynamic torque
% - F_a         scalar of aerodynamic thrust
% ----------------------------------
function [M_a,F_a] = Aerodynamics_BEM(x,v_0,Parameter)

    Omega   = x(1);
    x_T_dot = x(3);
    v_rel   = v_0 - x_T_dot;

    rho = 1.225;
    z   = 3;
    R   = 63.0;

    rNodes  = Parameter.BEM.RNodes;
    chord   = Parameter.BEM.Chord;
    twist   = Parameter.BEM.AeroTwst;
    drNodes = Parameter.BEM.DRNodes;
    
    n_nodes = length(rNodes);

    persistent a_prev a_prime_prev
    if isempty(a_prev) || length(a_prev) ~= n_nodes
        a_prev = zeros(n_nodes, 1);
        a_prime_prev = zeros(n_nodes, 1);
    end

    dT = zeros(n_nodes, 1);
    dM = zeros(n_nodes, 1);

    for i = 1:n_nodes
        r = rNodes(i);
        c = chord(i);
        beta = twist(i); 
        
        sigma_r = (z * c) / (2 * pi * r);
        lambda_r = (Omega * r) / max(v_rel, 0.1); 
        
        a = a_prev(i);
        a_prime = a_prime_prev(i);
        
        tol = 1e-5;
        error = 1;
        iter = 0;
        max_iter = 100;
        
        while error > tol && iter < max_iter
            a_old = a;
            a_prime_old = a_prime;
            
            phi = atan2((1 - a), (lambda_r * (1 + a_prime)));
            alpha_deg = rad2deg(phi) - beta;
            
            Cl = interp1(Parameter.BEM.AoA, Parameter.BEM.Cl, alpha_deg, 'linear', 'extrap');
            Cd = interp1(Parameter.BEM.AoA, Parameter.BEM.Cd, alpha_deg, 'linear', 'extrap');
            
            f_tip = (z / 2) * (R - r) / (r * max(abs(sin(phi)), 1e-5));
            if f_tip > 20
                Q = 1.0;
            else
                Q = (2 / pi) * acos(exp(-f_tip));
            end
            Q = max(Q, 0.001); 
            
            RHS_a = (sigma_r * (Cl * cos(phi) + Cd * sin(phi))) / (4 * Q * sin(phi)^2);
            RHS_aprime = (sigma_r * (Cl * sin(phi) - Cd * cos(phi))) / (4 * Q * lambda_r * sin(phi)^2);
            
            a = RHS_a / (1 + RHS_a);
            a_prime = RHS_aprime * (1 - a); 
            
            error = max(abs(a - a_old), abs(a_prime - a_prime_old));
            iter = iter + 1;
        end
        
        a_prev(i) = a;
        a_prime_prev(i) = a_prime;
        
        Vrel_sq = (v_rel^2 * (1 - a)^2) / max(sin(phi)^2, 1e-5); 
        
        dT(i) = sigma_r * pi * rho * Vrel_sq * (Cl * cos(phi) + Cd * sin(phi)) * r;
        dM(i) = sigma_r * pi * rho * Vrel_sq * (Cl * sin(phi) - Cd * cos(phi)) * r^2;
    end

    F_a = sum(dT .* drNodes);
    M_a = sum(dM .* drNodes);

end