// C++ program to display 
// Prime numbers till N
#include <bits/stdc++.h>
using namespace std;
 
// Function to check if a 
// given number is prime
bool isPrime(int n)
{
      // Since 0 and 1 is not 
      // prime return false.
      if(n == 1 || n == 0) return false;
   
      // Run a loop from 2 to n-1
      for(int i = 2; i < n; i++)
      {
        // if the number is divisible by i, 
        // then n is not a prime number.
        if(n % i == 0) return false;
      }
      // Otherwise n is a prime number.
      return true;
}
 
// Driver code
int main()
{
    int N = 10000000;
 
      // Check for every number from 1 to N
      for(int i = 1; i <= N; i++)
      {
          // Check if current number is prime
          if(isPrime(i)) 
          {
            cout << i << "\n";
          }
          sleep( 1 );
    }
 
    return 0;
}
