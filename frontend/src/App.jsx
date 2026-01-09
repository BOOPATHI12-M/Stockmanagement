import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { GoogleOAuthProvider } from '@react-oauth/google'
import { AuthProvider } from './context/AuthContext'
import { CartProvider } from './context/CartContext'

// Customer Pages
import Home from './pages/Home'
import Login from './pages/Login'
import Cart from './pages/Cart'
import Checkout from './pages/Checkout'
import Orders from './pages/Orders'
import TrackOrder from './pages/TrackOrder'
import TrackOrderSearch from './pages/TrackOrderSearch'
import Profile from './pages/Profile'

// Admin Pages
import AdminLogin from './admin/AdminLogin'
import AdminDashboard from './admin/AdminDashboard'
import AdminProducts from './admin/AdminProducts'
import AdminStock from './admin/AdminStock'
import AdminSuppliers from './admin/AdminSuppliers'
import AdminReports from './admin/AdminReports'
import AdminOrders from './admin/AdminOrders'
import Delivery from './admin/Delivery'
import UserManagement from './admin/UserManagement'

// Layout
import Navbar from './components/Navbar'
import ProtectedRoute from './components/ProtectedRoute'

const GOOGLE_CLIENT_ID = '524761068730-mu8649j0089sqvekrpltg52jlp5b6jor.apps.googleusercontent.com'

function App() {
  return (
    <GoogleOAuthProvider clientId={GOOGLE_CLIENT_ID}>
      <AuthProvider>
        <CartProvider>
          <Router future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
            <div className="min-h-screen" style={{ background: '#25252b' }}>
              <Navbar />
              <Routes>
                {/* Customer Routes */}
                <Route path="/" element={<Home />} />
                <Route path="/login" element={<Login />} />
                <Route 
                  path="/cart" 
                  element={
                    <ProtectedRoute requiredRole="CUSTOMER">
                      <Cart />
                    </ProtectedRoute>
                  } 
                />
                <Route 
                  path="/checkout" 
                  element={
                    <ProtectedRoute requiredRole="CUSTOMER">
                      <Checkout />
                    </ProtectedRoute>
                  } 
                />
                <Route 
                  path="/orders" 
                  element={
                    <ProtectedRoute requiredRole="CUSTOMER">
                      <Orders />
                    </ProtectedRoute>
                  } 
                />
                <Route path="/track" element={<TrackOrderSearch />} />
                <Route path="/track/:orderId" element={<TrackOrder />} />
                <Route 
                  path="/profile" 
                  element={
                    <ProtectedRoute>
                      <Profile />
                    </ProtectedRoute>
                  } 
                />
                
                {/* Admin Routes */}
                <Route path="/admin/login" element={<AdminLogin />} />
                <Route 
                  path="/admin/dashboard" 
                  element={
                    <ProtectedRoute requiredRole="ADMIN">
                      <AdminDashboard />
                    </ProtectedRoute>
                  } 
                />
                <Route 
                  path="/admin/products" 
                  element={
                    <ProtectedRoute requiredRole="ADMIN">
                      <AdminProducts />
                    </ProtectedRoute>
                  } 
                />
                <Route 
                  path="/admin/stock" 
                  element={
                    <ProtectedRoute requiredRole="ADMIN">
                      <AdminStock />
                    </ProtectedRoute>
                  } 
                />
                <Route 
                  path="/admin/suppliers" 
                  element={
                    <ProtectedRoute requiredRole="ADMIN">
                      <AdminSuppliers />
                    </ProtectedRoute>
                  } 
                />
                <Route 
                  path="/admin/reports" 
                  element={
                    <ProtectedRoute requiredRole="ADMIN">
                      <AdminReports />
                    </ProtectedRoute>
                  } 
                />
                <Route 
                  path="/admin/orders" 
                  element={
                    <ProtectedRoute requiredRole="ADMIN">
                      <AdminOrders />
                    </ProtectedRoute>
                  } 
                />
                <Route 
                  path="/delivery" 
                  element={
                    <ProtectedRoute requiredRole="DELIVERY_MAN">
                      <Delivery />
                    </ProtectedRoute>
                  } 
                />
                <Route 
                  path="/admin/users" 
                  element={
                    <ProtectedRoute requiredRole="ADMIN">
                      <UserManagement />
                    </ProtectedRoute>
                  } 
                />
              </Routes>
            </div>
          </Router>
        </CartProvider>
      </AuthProvider>
    </GoogleOAuthProvider>
  )
}

export default App

