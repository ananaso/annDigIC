function n = nneval(n,u)
%NNEVAL Evaluates the passed neural network. 
%   N = NNEVAL(N,U) Evaluates N with U as the input 
%
%   Author:  Cory Merkel - Rochester Institute of Technology


% Create new s vector and put in the bias and inputs
snew = zeros(n.nx,1);
snew(1) = 1;
snew(2:1+n.nu) = u;

% Evaluate the bias and input neurons
n.x(1) = snew(1);
n.x(2:1+n.nu) = snew(2:1+n.nu);  

% Iterate until stable
while 1
  
  % Calculate the rest of the s vector
  i = 1+n.nu+1:n.nx;
  snew(i) = (n.A(i,:).*n.W(i,:))*n.x;

  if snew == n.s
    break;
  else

    % Evaluate the hidden and output neurons
    n.s = snew;
    n.x(i) = n.f(n.s(i));

  end
end


