document.addEventListener('DOMContentLoaded', () => {
  // 1. Initialize Supabase Client using variables from config.js
  const supabaseUrl = typeof SUPABASE_URL !== 'undefined' ? SUPABASE_URL : '';
  const supabaseAnonKey = typeof SUPABASE_ANON_KEY !== 'undefined' ? SUPABASE_ANON_KEY : '';

  if (!supabaseUrl || !supabaseAnonKey || !window.supabase) {
    console.error('Supabase initialization failed: Missing URL/Key or Supabase JS SDK.');
    const errorDiv = document.getElementById('login-error');
    if (errorDiv) {
      errorDiv.textContent = 'Configuration error: Supabase client failed to load.';
    }
    return;
  }

  const supabase = window.supabase.createClient(supabaseUrl, supabaseAnonKey);

  // 2. DOM Elements
  const loginForm = document.getElementById('login-form');
  const loginEmail = document.getElementById('login-email');
  const loginPassword = document.getElementById('login-password');
  const loginBtn = document.getElementById('login-btn');
  const loginError = document.getElementById('login-error');

  const authSection = document.getElementById('auth-section');
  const mainAppSection = document.getElementById('main-app-section');
  const signoutBtn = document.getElementById('signout-btn');

  // 3. Check for existing active session on page load
  supabase.auth.getSession().then(({ data: { session } }) => {
    if (session) {
      showDashboard(session.user);
    }
  });

  // 4. Form Submission & Authentication Handling
  if (loginForm) {
    loginForm.addEventListener('submit', async (e) => {
      e.preventDefault(); // Stop default HTML form submission/page reload

      const email = loginEmail.value.trim();
      const password = loginPassword.value;

      if (!email || !password) {
        loginError.textContent = 'Please enter both email and password.';
        return;
      }

      // Provide immediate UI feedback
      loginBtn.disabled = true;
      loginError.style.color = '#333';
      loginError.textContent = 'Signing in...';

      try {
        const { data, error } = await supabase.auth.signInWithPassword({
          email: email,
          password: password,
        });

        if (error) {
          loginError.style.color = '#d9534f'; // Red error alert
          loginError.textContent = error.message;
          console.error('Sign-in error:', error.message);
        } else {
          loginError.textContent = '';
          showDashboard(data.user);
        }
      } catch (err) {
        loginError.style.color = '#d9534f';
        loginError.textContent = 'An unexpected error occurred. Please check browser console.';
        console.error('Unexpected sign-in error:', err);
      } finally {
        loginBtn.disabled = false;
      }
    });
  }

  // 5. Sign Out
  if (signoutBtn) {
    signoutBtn.addEventListener('click', async () => {
      await supabase.auth.signOut();
      if (mainAppSection) mainAppSection.style.display = 'none';
      if (authSection) authSection.style.display = 'block';
      if (loginError) loginError.textContent = '';
      if (loginForm) loginForm.reset();
    });
  }

  function showDashboard(user) {
    if (authSection) authSection.style.display = 'none';
    if (mainAppSection) mainAppSection.style.display = 'block';
  }
});
