function y = defdir(x)

if ~exist(x,'dir')
    mkdir(x);
    fprintf(1,['Created directory: \n', x ,'\n'])
end

y = x;
    