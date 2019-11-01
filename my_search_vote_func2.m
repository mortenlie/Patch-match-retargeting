function [res, ann, bnn] = my_search_vote_func2(S, T, niters, j, k, resultFolder, sceneName)

fprintf('Iteration progress: ');
%% Go th n iterations
for iter = 1:niters
    %% Searching for NNF
    if(iter==1)
        ann = mynnmex2(T, S, j,k,[]); 
        bnn = mynnmex2(S, T, j,k,[]);     
    else
        ann = mynnmex2(res, S, j,k,ann); 
        bnn = mynnmex2(S, res, j,k,bnn); 
    end
    
	%% Voting     
    res = double(myvotemex(S,T, ann, bnn,j,k)); 
    fprintf('#');
end
fprintf('\n');

