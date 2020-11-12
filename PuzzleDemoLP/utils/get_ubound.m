%% upper bound of the score we can get

function ubound = get_ubound(im_name,PP,nr,nc)

[pieceMat,ap,pi] = PuzzleFun(im_name,PP,nc,nr);

st = 0;
mask = zeros(nr,nc);

for j = 1:nc
    for i = 1:nr
        st = st + 1;
        piece = double(ap{st});
        mask(i,j) = var(piece(:)) == 0;
    end
end

randscram = ones(nr,nc);
ppp = 1:nr*nc;

real_goal = reshape(ppp,nr,nc);
real_goal(logical(mask)) = 0;

scores = eval_score(real_goal,ppp,randscram,nr,nc);
ubound = scores(1,:);