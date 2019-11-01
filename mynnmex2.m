function [ NN ] = mynnmex2(S,T,nPatchRows,nPatchCols,NN_init)
[Srows, Scols, ~] = size(S);
[Trows, Tcols, ~] = size(T);
w1 = floor(nPatchRows/2);
w2 = floor(nPatchCols/2);
NN = zeros(Trows-2*w1, Tcols-2*w2,3);

%% Initialization
if size(NN_init) == 0
    for i = 1:Trows-2*w1
        for j = 1:Tcols-2*w2
            NN(i,j,1) = randi([w1+1 Srows-w1]);
            NN(i,j,2) = randi([w2+1 Scols-w2]);
            Q = T(i:i-1+nPatchRows,j:j-1+nPatchCols,:); 
            P = S(NN(i,j,1)-w1:NN(i,j,1)+w1,NN(i,j,2)-w2:NN(i,j,2)+w2,:);
            NN(i,j,3) = D(P,Q);
        end
    end   
else
    NN = NN_init;
end

%% Forward propagation
for Trow = 1:Trows-2*w1
    for Tcol = 1:Tcols-2*w2        
        Q = T(Trow:Trow-1+nPatchRows,Tcol:Tcol-1+nPatchCols,:); 
        
        % Check left pixel's nearest neighbor
        if Tcol > 1 && NN(Trow,Tcol-1,2) < Scols-w2
            P_2 = S(NN(Trow,Tcol-1,1)-w1:NN(Trow,Tcol-1,1)+w1,NN(Trow,Tcol-1,2)-w2+1:NN(Trow,Tcol-1,2)+w2+1,:);
            distance_2 = D(P_2,Q);
            if distance_2 < NN(Trow,Tcol,3)
                NN(Trow,Tcol,1) = NN(Trow,Tcol-1,1);
                NN(Trow,Tcol,2) = NN(Trow,Tcol-1,2)+1;
                NN(Trow,Tcol,3) = distance_2;
            end
        end
               
        % Check above pixel's nearest neighbor
        if Trow > 1 && NN(Trow-1,Tcol,1)<Srows-w1
            P_3 = S(NN(Trow-1,Tcol,1)-w1+1:NN(Trow-1,Tcol,1)+w1+1,NN(Trow-1,Tcol,2)-w2:NN(Trow-1,Tcol,2)+w2,:);          
            distance_3 = D(P_3,Q);    
            if distance_3 < NN(Trow,Tcol,3)
                NN(Trow,Tcol,1) = NN(Trow-1,Tcol,1)+1;
                NN(Trow,Tcol,2) = NN(Trow-1,Tcol,2);
                NN(Trow,Tcol,3) = distance_3;
            end
        end         
        NN = random_search(S,T,nPatchRows,nPatchCols,NN,Trow,Tcol);
    end
end

%% Backward propagation
for Trow = Trows-2*w1:-1:1
    for Tcol = Tcols-2*w2:-1:1      
        Q = T(Trow:Trow-1+nPatchRows,Tcol:Tcol-1+nPatchCols,:);           

        % Check right pixel's nearest neighbor
        if Tcol < Tcols-2*w2 && NN(Trow,Tcol+1,2)-1 > w2           
            P_2 = S(NN(Trow,Tcol+1,1)-w1:NN(Trow,Tcol+1,1)+w1,NN(Trow,Tcol+1,2)-w2-1:NN(Trow,Tcol+1,2)+w2-1,:);
            distance_2 = D(P_2,Q);
            if distance_2 < NN(Trow,Tcol,3)
                NN(Trow,Tcol,1) = NN(Trow,Tcol+1,1);
                NN(Trow,Tcol,2) = NN(Trow,Tcol+1,2)-1;
                NN(Trow,Tcol,3) = distance_2;
            end
        end
               
        % Check below pixel's nearest neighbor
        if Trow < Trows-2*w1 && NN(Trow+1,Tcol,1)-1 > w1
            P_3 = S(NN(Trow+1,Tcol,1)-w1-1:NN(Trow+1,Tcol,1)+w1-1,NN(Trow+1,Tcol,2)-w2:NN(Trow+1,Tcol,2)+w2,:);          
            distance_3 = D(P_3,Q);    
            if distance_3 < NN(Trow,Tcol,3)
                NN(Trow,Tcol,1) = NN(Trow+1,Tcol,1)-1;
                NN(Trow,Tcol,2) = NN(Trow+1,Tcol,2);
                NN(Trow,Tcol,3) = distance_3;
            end
        end 
        NN = random_search(S,T,nPatchRows,nPatchCols,NN,Trow,Tcol);
    end
end

end