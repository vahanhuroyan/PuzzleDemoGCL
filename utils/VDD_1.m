function [ VDD ] = VDD_1( A )
%VDD_1 Summary of this function goes here
%   Detailed explanation goes here
    numbOfParts = size(A, 1);
%     [phi, mu] = eig(A);
    t = 21;
    used_svec = 20;
%     [phi, mu] = svd(A);
    [phi, mu] = eigs(A, used_svec);
    mu = real(diag(mu));

    VDM = zeros(used_svec, used_svec, numbOfParts);
    VDD = zeros(numbOfParts, numbOfParts);

    for kk = 1:numbOfParts
        VDM(:, :, kk) = phi(kk, 1:used_svec)' * phi(kk, 1:used_svec);
        VDM(:, :, kk) = (repmat(mu(1:used_svec), 1, used_svec)'.^t) .* (repmat(mu(1:used_svec), 1, used_svec).^t) .* VDM(:, :, kk);
    end
    
    for i = 1:numbOfParts
        disp(i);
        for j = 1:numbOfParts
%            VDD(i, j) = sqrt(trace(VDM(:, :, i) * VDM(:, :, i)') + trace(VDM(:, :, j) * VDM(:, :, j)') - 2 * trace(VDM(:, :, i) * VDM(:, :, j)')); 
            VDD(i, j) = norm(VDM(:, :, i) - VDM(:, :, j), 'fro');
        end
    end

end

