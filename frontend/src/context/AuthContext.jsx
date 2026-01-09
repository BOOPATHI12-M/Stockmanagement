import { createContext, useContext, useState, useEffect } from 'react'
import axios from 'axios'

// Provide default value to prevent errors during initial render
const defaultAuthValue = {
  user: null,
  token: null,
  login: () => {},
  logout: () => {},
  isAdmin: () => false,
  isDeliveryMan: () => false,
  loading: true
}

const AuthContext = createContext(defaultAuthValue)

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}

export const AuthProvider = ({ children }) => {
  // Initialize user from localStorage if available
  const [user, setUser] = useState(() => {
    try {
      const storedUser = localStorage.getItem('user')
      return storedUser ? JSON.parse(storedUser) : null
    } catch (error) {
      return null
    }
  })
  const [token, setToken] = useState(() => localStorage.getItem('token'))
  const [role, setRole] = useState(() => {
    // Get role from localStorage or from user object
    const storedRole = localStorage.getItem('role')
    if (storedRole) return storedRole
    try {
      const storedUser = localStorage.getItem('user')
      return storedUser ? JSON.parse(storedUser)?.role : null
    } catch (error) {
      return null
    }
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (token) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
      console.log('🔑 [AuthContext] Token set in axios defaults:', token.substring(0, 20) + '...')
    } else {
      delete axios.defaults.headers.common['Authorization']
      console.log('⚠️ [AuthContext] Token removed from axios defaults')
    }
    setLoading(false)
  }, [token])

  const login = async (token, userData) => {
    // Use the actual role from backend (CUSTOMER, ADMIN, or DELIVERY_MAN)
    const userRole = userData?.role || 'CUSTOMER'
    setToken(token)
    setUser(userData)
    setRole(userRole)
    
    // Store in localStorage for persistence across page refreshes
    localStorage.setItem('token', token)
    localStorage.setItem('user', JSON.stringify(userData))
    localStorage.setItem('role', userRole)
    
    // Set axios default header
    axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
    
    console.log('✅ [AuthContext] Login successful:', {
      username: userData?.username || userData?.email,
      role: userRole,
      tokenExists: !!token
    })
  }

  const logout = () => {
    setToken(null)
    setUser(null)
    setRole(null)
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    localStorage.removeItem('role')
    delete axios.defaults.headers.common['Authorization']
    console.log('🚪 [AuthContext] Logged out')
  }

  const isAdmin = () => {
    const currentRole = role || user?.role
    return currentRole === 'ADMIN'
  }

  const isDeliveryMan = () => {
    const currentRole = role || user?.role
    return currentRole === 'DELIVERY_MAN'
  }

  const isUser = () => {
    const currentRole = role || user?.role
    // CUSTOMER is the actual role name from backend, but we also support USER for compatibility
    return currentRole === 'CUSTOMER' || currentRole === 'USER'
  }

  const hasRole = (requiredRole) => {
    const currentRole = role || user?.role
    // Normalize roles: backend uses CUSTOMER, but we accept USER as equivalent
    const normalizedCurrentRole = currentRole === 'USER' ? 'CUSTOMER' : currentRole
    const normalizedRequiredRole = requiredRole === 'USER' ? 'CUSTOMER' : requiredRole
    
    // Check exact match or cross-compatibility (USER <-> CUSTOMER)
    return normalizedCurrentRole === normalizedRequiredRole || 
           (normalizedRequiredRole === 'CUSTOMER' && currentRole === 'USER') ||
           (normalizedRequiredRole === 'USER' && normalizedCurrentRole === 'CUSTOMER')
  }

  const value = {
    user,
    token,
    role,
    login,
    logout,
    isAdmin,
    isDeliveryMan,
    isUser,
    hasRole,
    loading
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

