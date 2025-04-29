function [X_k,P_k] = ekf(satPos,obs,settings,X,P,Q)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明


numSat = size(obs,2);


%% time update

X_kk = X;
% X_kk(4)=0;
P_kk = P+Q;

%% measurement update
    % Measurement Noise Covariance
    R_pseudo = 10;    % Pseudorange noise (meters)
    R_doppler = 1;    % Doppler noise (Hz)
    
    % Initialize measurement model
    H = zeros( numSat, size(X,2)); 
    Z = zeros( numSat, 1);  
    h_x = zeros( numSat, 1);  

    for i = 1:numSat

        %--- Update equations -----------------------------------------
            % rho2 = (satPos(1, i) - pos(1))^2 + (X(2, i) - pos(2))^2 + ...
            %     (X(3, i) - pos(3))^2;
        Xs = satPos(1, i);  Ys = satPos(2, i);  Zs = satPos(3, i);
        dX = Xs - X_kk(1);
        dY = Ys - X_kk(2);
        dZ = Zs - X_kk(3);
        rho = sqrt(dX^2 + dY^2 + dZ^2); % Range

        traveltime = rho / settings.c ;

            %--- Correct satellite position (do to earth rotation) --------
            % Convert SV position at signal transmitting time to position
            % at signal receiving time. ECEF always changes with time as
            % earth rotates.
            Rot_X = e_r_corr(traveltime, satPos(:, i));

            %--- Find the elevation angel of the satellite ----------------
            % [az(i), el(i), ~] = topocent(X_kk(1:3), Rot_X - X_k(1:3));

            % if (settings.useTropCorr == 1)
            %     %--- Calculate tropospheric correction --------------------
            %     trop = tropo(sin(el(i) * dtr), ...
            %         0.0, 1013.0, 293.0, 50.0, 0.0, 0.0, 0.0);
            % else
            %     % Do not calculate or apply the tropospheric corrections
            %     trop = 0;
            % end
            % weight(i)=sin(el(i))^2;

        Xs = Rot_X(1);  Ys = Rot_X(2);  Zs = Rot_X(3);
        dX = Xs - X_kk(1);
        dY = Ys - X_kk(2);
        dZ = Zs - X_kk(3);
        rho = sqrt(dX^2 + dY^2 + dZ^2); % Range



        % Pseudorange Measurement
        H(i, :) = [-dX/rho, -dY/rho, -dZ/rho,  1]; 
        Z(i) = obs(i) ; 
        h_x(i) = rho +  X_kk(4);


        % % Doppler Measurement
        % relVel = (dX*x_pred(4) + dY*x_pred(5) + dZ*x_pred(6)) / rho;
        % H(numSat + i, :) = [0, 0, 0, -dX/rho, -dY/rho, -dZ/rho, 0, c];
        % if i > length(doppler)  % Ensure index does not exceed doppler length
        %     Z(numSat + i) = 0;  % Assign zero if Doppler data is missing
        % else
        % Z(numSat + i) = doppler(i);
        % end
        % h_x(numSat + i) = relVel + c * x_pred(8);
    end

    % Measurement Noise Covariance Matrix
    R = diag(ones(1, numSat) * R_pseudo);%, ones(1, numSat) * R_doppler]);

    % Innovation Calculation
    r = Z - h_x; 
    S = H * P_kk * H' + R;
    K = P_kk * H' /S; % Kalman Gain

    % Update State Estimate
    X_k = X_kk + (K * r)';
    % P_k = (eye(size(X,2)) - K * H) * P_kk;
    I = eye(size(X, 2));
    P_k = (I - K * H) * P_kk * (I - K * H)' + K * R * K';
    P_k

end

