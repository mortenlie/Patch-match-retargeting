function [ out ] = valid_windowSize(alpha,i,Srows,Scols,nPatchRows,nPatchCols)
out = alpha^i*Srows > nPatchRows && alpha^i*Scols > nPatchCols;
end

