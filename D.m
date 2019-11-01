function [ distance ] = D( P,Q )
distance = sum(sum(sum((P-Q).^2,1),2),3)/(size(P,1)*size(P,2)*size(P,3));
end