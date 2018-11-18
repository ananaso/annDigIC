function [errors correct Y cm] = nngeterrors(n,P)
%NNGETERRORS Get the nn errors.
%   [ERRORS CORRECT CM TEST Y] = NNGETERRORS(N,P) calculates the errors in terms
%   of squared error, number of correct outputs (after a threshold is applied,
%   the actual network outputs, and the confusion matrix
%
%   Author:  Cory Merkel - Rochester Institute of Technology

errors = zeros(1,size(P,2));
correct = zeros(1,size(P,2));
Y = zeros(n.ny,size(P,2));
cm = zeros(n.ny,n.ny);
for p=1:size(P,2)
  u = P(1:n.nu,p);
  c = P(n.nu+1:n.nu+n.ny,p);
  n = nneval(n,u);
  errors(p) = sum((c-n.x(1+n.nu+n.nh+1:n.nx)).^2);
  y = n.x(1+n.nu+n.nh+1:n.nx);
  Y(:,p) = y;

  % MAXNET output
  %y(y==max(y)) = 1.0;
  %y(y<1.0) = 0;
  %if y == c,
  %  correct(p) = 1.0;
  %end
  
  % Uses rounding 
  if round(y) == c
    correct(p) = 1.0;
  end

  cm(find(c),find(y))=cm(find(c),find(y))+1;

end
