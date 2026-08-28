import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Navbar } from './components/layout/Navbar';
import { Footer } from './components/layout/Footer';
import { Home } from './pages/home/Home';
import { Login } from './pages/auth/Login';
import { Register } from './pages/auth/Register';

function App() {
  return (
    <BrowserRouter>
      <div className="flex flex-col min-h-screen w-full antialiased font-sans">
        {/* Global Navigation Bar */}
        <Navbar />

        {/* Route Views */}
        <Routes>
          {/* Main Landing Route */}
          <Route path="/" element={<Home />} />

          {/* Dedicated Auth Routes */}
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />

          {/* Catch-all redirect */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>

        {/* Global Footer */}
        <Footer />
      </div>
    </BrowserRouter>
  );
}

export default App;





