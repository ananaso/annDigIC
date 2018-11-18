function n = nnnew(nu,nh,ny,f,fp,wmax,wmin) 
%NNNEW Creates a new neural network structures.
%   N = NNNEW(NU,NH,NY) creates an MLP with NU inputs, NH hidden neurons,
%   and NY output neurons.
%   If NH = 0, then N will be a single-layer Perceptron
%
%   Author:  Cory Merkel - Rochester Institute of Technology

n.nu = nu;                  % Number of nn inputs
n.nh = nh;                  % Number of nn hidden neurons
n.ny = ny;                  % Number of nn outputs
n.nx = (nu+1)+nh+ny;        % State includes input and bias
n.x = zeros(n.nx,1);        % State vector
n.s = zeros(n.nx,1);        % Input of each neuron
n.W = zeros(n.nx);          % Weight matrix
n.wmax = wmax;              % Maximum weight value
n.wmin = wmin;              % Minimum weight value
n.A = zeros(n.nx);          % Adjacency matrix
n.f = f;                    % Activation function
n.fp = fp;                  % Derivative of activation function

% Setup the adjacency matrix and initialize weights
%% Input layer to hidden layer (or output layer if nh = 0)
nl2 = n.nh;
if n.nh == 0
  nl2 = n.ny;
end
for i=1+nu+1:1+nu+nl2
  n.A(i,1) = 1;
  n.W(i,1) = random('uniform',-1.0,1.0);
  for j=2:1+nu
    n.A(i,j) = 1;
    n.W(i,j) = random('uniform',-1.0,1.0);
  end
end

%% Hidden layer to output layer
if n.nh > 0
  for i=1+nu+nh+1:1+nu+nh+ny
    n.A(i,1) = 1;
    n.W(i,1) = random('uniform',-1.0,1.0);
    for j=1+nu+1:1+nu+nh
      n.A(i,j) = 1;
      n.W(i,j) = random('uniform',-1.0,1.0);
    end
  end
end

