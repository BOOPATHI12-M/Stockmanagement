import axios from 'axios'

// Use environment variable for API URL in production (Render)
// In development, use Vite proxy or localhost
const API_BASE_URL = import.meta.env.VITE_API_URL || 
  (import.meta.env.DEV ? '/api' : 'http://localhost:8080/api')

console.log('🔗 [API] Base URL:', API_BASE_URL)

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json'
  }
})

// Add token to requests - Enhanced for cross-browser compatibility
api.interceptors.request.use((config) => {
  // Always get fresh token from localStorage to handle browser differences
  const token = localStorage.getItem('token')
  const role = localStorage.getItem('role')
  
  if (token) {
    // Ensure Authorization header is set correctly
    config.headers.Authorization = `Bearer ${token}`
    console.log('🔑 [API Interceptor] Adding token to request:', {
      url: config.url,
      method: config.method,
      tokenExists: !!token,
      tokenPreview: token.substring(0, 20) + '...',
      role: role || 'unknown'
    })
  } else {
    console.warn('⚠️ [API Interceptor] No token found for request:', {
      url: config.url,
      method: config.method
    })
    // Remove Authorization header if no token
    delete config.headers.Authorization
  }
  
  // Ensure Content-Type is set for non-form-data requests
  if (!config.headers['Content-Type'] && !(config.data instanceof FormData)) {
    config.headers['Content-Type'] = 'application/json'
  }
  
  return config
}, (error) => {
  console.error('❌ [API Interceptor] Request error:', error)
  return Promise.reject(error)
})

// Handle response errors globally
api.interceptors.response.use(
  (response) => {
    // Log successful responses for debugging (optional, can be removed in production)
    if (response.config?.url?.includes('/orders/all')) {
      console.log('✅ [API Interceptor] Orders response received:', {
        status: response.status,
        dataLength: Array.isArray(response.data) ? response.data.length : 'N/A'
      })
    }
    return response
  },
  (error) => {
    const status = error.response?.status
    const url = error.config?.url
    
    if (status === 401) {
      console.error('🔒 [API Interceptor] 401 Unauthorized:', {
        url,
        message: error.response?.data?.error || 'Authentication failed',
        tokenExists: !!localStorage.getItem('token')
      })
      // Optionally clear auth data and redirect
      // localStorage.removeItem('token')
      // localStorage.removeItem('user')
      // localStorage.removeItem('role')
      // window.location.href = '/login'
    } else if (status === 403) {
      console.error('🚫 [API Interceptor] 403 Forbidden:', {
        url,
        message: error.response?.data?.error || 'Access denied',
        role: localStorage.getItem('role')
      })
    } else if (status >= 500) {
      console.error('💥 [API Interceptor] Server error:', {
        url,
        status,
        message: error.response?.data?.error || error.message
      })
    }
    
    return Promise.reject(error)
  }
)

// Product APIs
export const getProducts = () => api.get('/products')
export const getProduct = (id) => api.get(`/products/${id}`)
export const uploadProductImage = (file) => {
  const formData = new FormData()
  formData.append('file', file)
  return api.post('/products/upload', formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// Auth APIs
export const googleLogin = (data) => api.post('/auth/customer/google', data)
export const customerLogin = (data) => api.post('/auth/customer/login', data)
export const setPassword = (data) => api.post('/auth/customer/set-password', data)
export const sendOtp = (data) => api.post('/auth/customer/send-otp', data)
export const verifyOtp = (data) => api.post('/auth/customer/verify-otp', data)
export const adminLogin = (data) => api.post('/auth/admin/login', data)
export const getProfile = () => api.get('/auth/profile')
export const updateProfile = (data) => api.put('/auth/profile', data)
export const changePassword = (data) => api.post('/auth/change-password', data)

// Address APIs
export const getAddresses = () => api.get('/auth/profile/addresses')
export const addAddress = (data) => api.post('/auth/profile/addresses', data)
export const updateAddress = (id, data) => api.put(`/auth/profile/addresses/${id}`, data)
export const deleteAddress = (id) => api.delete(`/auth/profile/addresses/${id}`)
export const setDefaultAddress = (id) => api.post(`/auth/profile/addresses/${id}/set-default`)

// Order APIs
export const createOrder = (data) => api.post('/orders', data)
export const getOrder = (id) => api.get(`/orders/${id}`)
export const getMyOrders = () => api.get('/orders/customer/me')
export const getCustomerOrders = (customerId) => api.get(`/orders/customer/${customerId}`)
export const getAllOrders = () => api.get('/orders/all')
export const updateOrderStatus = (id, status, cancellationReason = null) => {
  const payload = { status }
  if (cancellationReason) {
    payload.cancellationReason = cancellationReason
  }
  return api.patch(`/orders/${id}/status`, payload)
}
export const getTracking = (id) => api.get(`/orders/${id}/tracking`)
export const getLocationTracking = (id) => api.get(`/orders/${id}/location-tracking`)
export const getOrderByOrderNumber = (orderNumber) => api.get(`/orders/by-order-number/${orderNumber}`)
export const getOrderByTrackingId = (trackingId) => api.get(`/orders/by-tracking-id/${trackingId}`)

// Stock APIs
export const stockIn = (data) => api.post('/stock/in', data)
export const stockOut = (data) => api.post('/stock/out', data)
export const getStockHistory = (productId) => api.get(`/stock/history/${productId}`)

// Supplier APIs
export const getSuppliers = () => api.get('/suppliers')
export const createSupplier = (data) => api.post('/suppliers', data)
export const updateSupplier = (id, data) => api.put(`/suppliers/${id}`, data)
export const deleteSupplier = (id) => api.delete(`/suppliers/${id}`)

// Report APIs
export const getSummary = () => api.get('/reports/summary')

// Admin APIs
export const createDeliveryMan = (formData) => {
  return api.post('/auth/admin/create-delivery-man', formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}
export const getDeliveryMen = () => api.get('/auth/admin/delivery-men')
export const updateDeliveryMan = (id, data) => api.put(`/auth/admin/delivery-men/${id}`, data)
export const deleteDeliveryMan = (id) => api.delete(`/auth/admin/delivery-men/${id}`)
export const getAllUsers = () => api.get('/auth/admin/users')

// Delivery Man APIs
export const getMyDeliveryOrders = () => api.get('/delivery/my-orders')
export const getAvailableOrders = () => api.get('/delivery/available-orders')
export const acceptOrder = (orderId) => api.post(`/delivery/orders/${orderId}/accept`)
export const updateDeliveryOrderStatus = (orderId, status) => api.post(`/delivery/orders/${orderId}/update-status`, { status })
export const updateDeliveryLocation = (orderId, locationData) => api.post(`/delivery/orders/${orderId}/update-location`, locationData)
export const getDeliveryOrderDetails = (orderId) => api.get(`/delivery/orders/${orderId}`)
export const generateFakeLocations = (orderId) => api.post(`/delivery/orders/${orderId}/generate-fake-locations`)

// Cart APIs
export const getCart = () => api.get('/cart')
export const addToCart = (productId, quantity = 1) => api.post('/cart/items', { productId, quantity })
export const updateCartItem = (itemId, quantity) => api.put(`/cart/items/${itemId}`, { quantity })
export const removeCartItem = (itemId) => api.delete(`/cart/items/${itemId}`)
export const clearCart = () => api.delete('/cart')

// Review APIs
export const getProductReviews = (productId) => api.get(`/reviews/product/${productId}`)
export const addReview = (productId, data) => api.post(`/reviews/product/${productId}`, data)
export const deleteReview = (reviewId) => api.delete(`/reviews/${reviewId}`)
export const getMyReviews = () => api.get('/reviews/user/me')


export default api

