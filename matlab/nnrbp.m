function [n traininfo] = nnrbp(n,T,G,epochs)
%NNRBP Resilient backpropagation algorithm
%   [n traininfo] = NNRBP(N,T,G,EPOCHS) trains the passed network
%   on training set T using RPROP
%
%   Author:  Cory Merkel - Rochester Institute of Technology


trainerrors = zeros(epochs,size(T,2));
testerrors = zeros(epochs,size(G,2));
traincorrect = zeros(epochs,size(T,2));
testcorrect = zeros(epochs,size(G,2)); 

delt = 0.1*ones(n.nx,n.nx);  
deltmax = 0.05;
deltmin = 1e-6;
etan    = 0.5;
etap    = 1.2;
dEdWlast = zeros(n.nx);
dW = zeros(n.nx);

% Calculate the partial derivatives
for epoch=1:epochs
  dEdW = zeros(n.nx);
  for t=1:size(T,2)
    u = T(1:n.nu,t);
    c = T(n.nu+1:n.nu+n.ny,t);
    n = nneval(n,u);
    d = zeros(1,n.nx);
    for i=1+n.nu+n.nh+1:n.nx
      d(i) = (c(i-1-n.nu-n.nh)-n.x(i))*n.fp(n.s(i));
    end
    for i=1+n.nu+n.nh:-1:1+n.nu+1
      for j=i+1:n.nx
        d(i) = d(i) + n.W(j,i)*d(j);
      end
      d(i) = d(i)*n.fp(n.s(i));
    end
    for i=1:n.nx
      for j=1:n.nx
        if n.A(i,j) == 1
          dEdW(i,j) = dEdW(i,j) - d(i)*n.x(j);
        end
      end
    end
  end
  
  % Perform the weight updates
  for i=1:n.nx
    for j=1:n.nx
      if n.A(i,j) == 1
        if dEdWlast(i,j)*dEdW(i,j) > 0
          delt(i,j) = min(delt(i,j)*etap,deltmax);
          dW(i,j) = -sign(dEdW(i,j))*delt(i,j);
          n.W(i,j) = n.W(i,j) + dW(i,j);
        elseif dEdWlast(i,j)*dEdW(i,j) < 0
          delt(i,j) = max(delt(i,j)*etan,deltmin);
          n.W(i,j) = n.W(i,j) - dW(i,j);
          dEdW(i,j) = 0;
        else
          dW(i,j) = -sign(dEdW(i,j))*delt(i,j);
          n.W(i,j) = n.W(i,j) + dW(i,j);
        end
      end
    end
  end
  
  dEdWlast = dEdW;
  
  % Restrict weights
  n.W(n.W<n.wmin) = n.wmin;
  n.W(n.W>n.wmax) = n.wmax;

  % Display epoch results
  [trainerrors(epoch,:) traincorrect(epoch,:)] = nngeterrors(n,T);
  [testerrors(epoch,:) testcorrect(epoch,:)] = nngeterrors(n,G);
  fprintf('Epoch: %d\n  Sum Train Error: %f Train Accuracy: %3.2f%%\n  Sum Test Error: %f Test Accuracy: %3.2f%%\n',...
  epoch,sum(trainerrors(epoch,:)),100*sum(traincorrect(epoch,:))/size(T,2),sum(testerrors(epoch,:)),100*sum(testcorrect(epoch,:))/size(G,2));
end

traininfo = {trainerrors traincorrect testerrors testcorrect};
  
