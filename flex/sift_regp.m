function H = sift_regp(f1, d1, f2, d2)
%SIFT_REGP Summary of this function goes here
%   Detailed explanation goes here

% match
[matches, ~] = vl_ubcmatch(d1, d2);

numMatches = size(matches, 2);

X1 = f1(1:2, matches(1,:)); X1(3, :) = 1;
X2 = f2(1:2, matches(2,:)); X2(3, :) = 1;

% RANSAC with homography model
H = cell(1, 100); ok = cell(1, 100); score = zeros(1, 100);
for t = 1:100
    % estimate homograpyh
    subset = vl_colsubset(1:numMatches, 4);
    A = [];
    for i = subset
        A = cat(1, A, kron(X1(:, i)', vl_hat(X2(:, i))));
    end
    [~, ~, V] = svd(A) ;
    H{t} = reshape(V(:, 9), 3, 3);

    % score homography
    X2_ = H{t} * X1 ;
    du = X2_(1, :) ./ X2_(3, :) - X2(1, :) ./ X2(3, :);
    dv = X2_(2, :) ./ X2_(3, :) - X2(2, :) ./ X2(3, :);
    ok{t} = (du .* du + dv .* dv) < 6 * 6;
    score(t) = sum(ok{t});
end

[~, best] = max(score);
H = H{best};
ok = ok{best};

% refine
if exist('fminsearch', 'file')
    H = H / H(3, 3);
    opts = optimset('Display', 'none', 'TolFun', 1e-8, 'TolX', 1e-8);
    H(1:8) = fminsearch(@residual, H(1:8)', opts);
else
    warning('Refinement disabled as fminsearch was not found.');
end

% error
function err = residual(H)
    lu = H(1) * X1(1, ok) + H(4) * X1(2, ok) + H(7);
    lv = H(2) * X1(1, ok) + H(5) * X1(2, ok) + H(8);
    d = H(3) * X1(1, ok) + H(6) * X1(2, ok) + 1;
    ldu = X2(1, ok) - lu ./ d;
    ldv = X2(2, ok) - lv ./ d;
    err = sum(ldu .* ldu + ldv .* ldv);
end

end

