import { Navigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

/**
 * ProtectedRoute Component
 * Provides role-based route protection
 * 
 * @param {Object} props
 * @param {React.ReactNode} props.children - The component to render if authorized
 * @param {boolean} props.adminOnly - If true, only ADMIN role can access
 * @param {string} props.requiredRole - Specific role required: 'USER', 'DELIVERY_MAN', or 'ADMIN'
 * @param {string[]} props.allowedRoles - Array of allowed roles (alternative to requiredRole)
 */
export default function ProtectedRoute({ 
  children, 
  adminOnly = false, 
  requiredRole = null,
  allowedRoles = null 
}) {
  const { user, token, role, loading, isAdmin, isDeliveryMan, isUser, hasRole } = useAuth()

  // Show loading state
  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen">
        <div className="text-center">
          <svg className="animate-spin h-12 w-12 mx-auto mb-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" style={{ color: '#06b6d4' }}>
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <p style={{ color: 'rgba(255, 255, 255, 0.7)' }}>Loading...</p>
        </div>
      </div>
    )
  }

  // Check if user is authenticated
  if (!user || !token) {
    console.log('🚫 [ProtectedRoute] No user or token, redirecting to login')
    return <Navigate to={adminOnly ? '/admin/login' : '/login'} replace />
  }

  const currentRole = role || user?.role
  // Normalize role: backend uses CUSTOMER, but we also accept USER for compatibility
  const normalizedRole = currentRole === 'USER' ? 'CUSTOMER' : currentRole
  console.log('🔍 [ProtectedRoute] Checking access:', {
    currentRole,
    normalizedRole,
    adminOnly,
    requiredRole,
    allowedRoles,
    isAdmin: isAdmin(),
    isDeliveryMan: isDeliveryMan(),
    isUser: isUser()
  })

  // Check adminOnly (legacy support)
  if (adminOnly && !isAdmin()) {
    console.log('🚫 [ProtectedRoute] Admin only route, but user is not ADMIN')
    return <Navigate to="/" replace />
  }

  // Check requiredRole (with role normalization)
  if (requiredRole) {
    // Normalize requiredRole: USER -> CUSTOMER
    const normalizedRequiredRole = requiredRole === 'USER' ? 'CUSTOMER' : requiredRole
    // Check if current role matches (with normalization)
    const roleMatches = normalizedRole === normalizedRequiredRole || 
                        (normalizedRequiredRole === 'CUSTOMER' && (normalizedRole === 'CUSTOMER' || currentRole === 'USER')) ||
                        (normalizedRequiredRole === 'USER' && (normalizedRole === 'CUSTOMER' || currentRole === 'USER'))
    
    if (!roleMatches) {
      console.log(`🚫 [ProtectedRoute] Required role ${requiredRole} (normalized: ${normalizedRequiredRole}) not met. Current role: ${currentRole} (normalized: ${normalizedRole})`)
      return <Navigate to="/" replace />
    }
  }

  // Check allowedRoles (with role normalization)
  if (allowedRoles && allowedRoles.length > 0) {
    const normalizedAllowedRoles = allowedRoles.map(r => r === 'USER' ? 'CUSTOMER' : r)
    const hasAllowedRole = normalizedAllowedRoles.includes(normalizedRole) || 
                           (normalizedAllowedRoles.includes('CUSTOMER') && currentRole === 'USER') ||
                           (normalizedAllowedRoles.includes('USER') && normalizedRole === 'CUSTOMER')
    
    if (!hasAllowedRole) {
      console.log(`🚫 [ProtectedRoute] User role ${currentRole} (normalized: ${normalizedRole}) not in allowed roles:`, allowedRoles, '(normalized:', normalizedAllowedRoles, ')')
      return <Navigate to="/" replace />
    }
  }

  console.log('✅ [ProtectedRoute] Access granted')
  return children
}


