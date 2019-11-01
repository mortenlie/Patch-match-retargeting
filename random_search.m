function [ NN ] = random_search(S,T,nPatchRows,nPatchCols,NN,Trow,Tcol)
[Srows, Scols, ~] = size(S);
w1 = floor(nPatchRows/2);
w2 = floor(nPatchCols/2);
alpha = 0.5;
i = 0;
q = [NN(Trow,Tcol,1) NN(Trow,Tcol,2)];

Q = T(Trow:Trow-1+nPatchRows,Tcol:Tcol-1+nPatchCols,:);
while valid_windowSize(alpha,i,Srows,Scols,nPatchRows,nPatchCols) 
    W = floor([alpha^i*Srows alpha^i*Scols]);
    
    % Resize window
    if i > 0
        %Re-adjust random search borders, le=left_edge, ue = above_edge
        ae = 1;
        le = 1;
        %Adjust row placement
        middle_offset(1) = q(1)-(floor(W(1)/2)+ae-1);
        while middle_offset(1) > 0 && ae < Srows-W(1)
            ae = ae + 1;
            middle_offset(1) = q(1)-(floor(W(1)/2)+ae-1);               
        end        
        %Adjust columnm placement
        middle_offset(2) = q(2)-(floor(W(2)/2)+le-1);
        while middle_offset(2) > 0 && le < Scols-W(2)
            le = le + 1;
            middle_offset(2) = q(2)-(floor(W(2)/2)+le-1); 
        end       
    else
        ae = 0; le = 0;
    end
    
    rand_window = [1+w1+ae W(1)-w1+ae; 1+w2+le W(2)-w2+le];
    rand_row = randi([rand_window(1,1) rand_window(1,2)]);
    rand_col = randi([rand_window(2,1) rand_window(2,2)]);
    P_r = S(rand_row-w1:rand_row+w1,rand_col-w2:rand_col+w2,:);

    distance = D(Q,P_r);
    if distance < NN(Trow,Tcol,3)
        NN(Trow,Tcol,1) = rand_row;
        NN(Trow,Tcol,2) = rand_col;
        NN(Trow,Tcol,3) = distance;
    end  
    i = i + 1;
end

