function sda( alpha)

% Steepest Descent Analytical

M = 10000;
x = [ -1; +1];

for m=1:M
  g(1,1) = -400*x(1,1)*( x(2,1) - x(1,1)^2) - 2*( 1 - x(1,1));
  g(2,1) = 200*( x(2,1) - x(1,1)^2);
  x    = x - alpha*g;
  out(m,:) = x';
end

figure; plot( 1:M, out(:,1), 'r-', 1:M, out(:,2), 'b-');