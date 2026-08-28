import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { Navbar } from "./components/layout/Navbar";
import { Footer } from "./components/layout/Footer";
import { Home } from "./pages/home/Home";
import { Login } from "./pages/auth/Login";
import { Register } from "./pages/auth/Register";
import { Dashboard as AdminDashboard } from "./admin/dashboard/pages/Dashboard";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Admin Dashboard Routes (Full Screen Workspace) */}
        <Route path="/admin" element={<AdminDashboard />} />
        <Route path="/admin/dashboard" element={<AdminDashboard />} />

        {/* Public Website Routes (With Global Navbar & Footer) */}
        <Route
          path="/*"
          element={
            <div className="flex flex-col min-h-screen w-full antialiased font-sans">
              <Navbar />
              <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/login" element={<Login />} />
                <Route path="/register" element={<Register />} />
                <Route path="*" element={<Navigate to="/" replace />} />
              </Routes>
              <Footer />
            </div>
          }
        />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
