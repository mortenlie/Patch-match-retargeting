function [ res ] = myvotemex( S,T,ann,bnn,nPatchRows,nPatchCols)
[SRows, SCols, SChs] = size(S);
[TRows, TCols, TChs] = size(T);
w1 = floor(nPatchRows/2);
w2 = floor(nPatchCols/2);

%% Vote the complete part
complete_sum = zeros(TRows, TCols, TChs);
norm_matrix_complete = zeros(TRows, TCols, TChs);
for ch = 1:SChs
    for row = w1+1:SRows-w1     
        for col = w2+1:SCols-w2
            patch = double(S(row-w1:row+w1,col-w2:col+w2,ch));
            q = [ann(row-w1,col-w2,1) ann(row-w1,col-w2,2)];
            for i = 1:nPatchRows
                for j = 1:nPatchCols
                    complete_sum(q(1)-w1+i-1,q(2)-w2+j-1,ch) = complete_sum(q(1)-w1+i-1,q(2)-w2+j-1,ch) + patch(i,j);
                    norm_matrix_complete(q(1)-w1+i-1,q(2)-w2+j-1,ch) = norm_matrix_complete(q(1)-w1+i-1,q(2)-w2+j-1,ch)+1;
                end
            end
        end
    end
end


%% Vote the coherence part
coherence_sum = zeros(TRows, TCols, TChs);
norm_matrix_coherence = zeros(TRows, TCols, TChs);
for ch = 1:TChs
    for row = 1:TRows-2*w1
        for col = 1:TCols-2*w2
            patch = double(S(bnn(row,col,1)-w1:bnn(row,col,1)+w1,bnn(row,col,2)-w2:bnn(row,col,2)+w2,ch));
            for i = 1:nPatchRows
                for j = 1:nPatchCols
                    coherence_sum(row+i-1,col+j-1,ch) = coherence_sum(row+i-1,col+j-1,ch)+ patch(i,j);
                    norm_matrix_coherence(row+i-1,col+j-1,ch) = norm_matrix_coherence(row+i-1,col+j-1,ch)+1;
                end
            end
        end
    end
end

%% Extract result
res = zeros(TRows,TCols,TChs);
Ns = (SRows-2*w1-1)*(SCols-2*w2-1); % #Patches in source
Nt = (TRows-2*w1-1)*(TCols-2*w2-1); % #Patches in target

for ch = 1:TChs
    for row = 1:TRows
        for col = 1:TCols
            res(row,col,ch) = (1/Ns*complete_sum(row,col,ch)+1/Nt*coherence_sum(row,col,ch))/(norm_matrix_complete(row,col,ch)/Ns+norm_matrix_coherence(row,col,ch)/Nt);
        end
    end
end
res = uint8(res);
end

