# Real Estate Marketing CRM - Frontend

A production-ready React.js application for managing real estate marketing campaigns, contacts, and audiences with role-based access control.

## 🚀 Features

- **Role-Based Access Control**: Separate dashboards for Super Admin, Organization Admin, and Organization User
- **Complete CRUD Operations**: Organizations, Users, Contacts, and Audiences management
- **Contact Import**: Bulk import contacts via CSV files
- **Audience Management**: Create and manage targeted audience segments
- **Clean UI Design**: Simple, single-color theme inspired by government portals
- **Redux State Management**: Centralized state with Redux Toolkit
- **Responsive Design**: Works seamlessly across devices
- **Production Ready**: Optimized code structure and best practices

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (version 14.x or higher)
- **npm** (version 6.x or higher) or **yarn**
- **Backend API** running on `http://localhost:3000`

## 🛠️ Getting Started

### 1. Install Dependencies

```bash
cd Frontend
npm install
```

### 2. Environment Configuration

The `.env` file is already configured with default values:

```env
REACT_APP_API_URL=http://localhost:3000/api/v1
```

Update this if your backend API is running on a different URL.

### 3. Start Development Server

```bash
npm start
```

The application will open in your browser at `http://localhost:3001`

### 4. Build for Production

```bash
npm run build
```

This creates an optimized production build in the `build` folder.

## 📁 Project Structure

```
Frontend/
├── public/                 # Static files
│   └── index.html         # HTML template
├── src/
│   ├── components/        # Reusable React components
│   │   ├── Button.js
│   │   ├── Input.js
│   │   ├── Select.js
│   │   ├── Table.js
│   │   ├── Modal.js
│   │   ├── Card.js
│   │   ├── Sidebar.js
│   │   ├── Header.js
│   │   ├── Layout.js
│   │   └── PrivateRoute.js
│   ├── pages/             # Page components
│   │   ├── Login.js
│   │   ├── Dashboard.js
│   │   ├── Organizations.js
│   │   ├── Users.js
│   │   ├── Contacts.js
│   │   ├── Audiences.js
│   │   ├── ImportLogs.js
│   │   └── Unauthorized.js
│   ├── services/          # API service files
│   │   ├── api.js
│   │   ├── authService.js
│   │   ├── organizationService.js
│   │   ├── userService.js
│   │   ├── contactService.js
│   │   ├── audienceService.js
│   │   └── importLogService.js
│   ├── store/             # Redux store
│   │   ├── index.js
│   │   └── authSlice.js
│   ├── utils/             # Utility functions
│   │   ├── constants.js
│   │   ├── permissions.js
│   │   └── helpers.js
│   ├── styles/            # CSS files
│   │   ├── index.css
│   │   └── components.css
│   ├── App.js             # Main application component
│   └── index.js           # Application entry point
├── .env                   # Environment variables
├── .gitignore            # Git ignore file
├── package.json          # Dependencies and scripts
└── README.md             # This file
```

## 🔑 Default Login Credentials

```
Email: hdlukare@gmail.com
Password: Password@123
```

## 👥 User Roles

### 1. Super Admin
- Access to all features
- Manage organizations
- Manage all users
- Manage contacts, audiences, and campaigns
- View import logs

### 2. Organization Admin
- Manage users within their organization
- Manage contacts
- Create and manage audiences
- View import logs

### 3. Organization User
- View contacts
- View audiences
- Limited access based on organization

## 🎨 Design Theme

The UI follows a clean, simple design inspired by government portals with:
- Primary color: Blue (`#1e3a8a`)
- No gradients - solid colors only
- Clean typography
- Professional layout
- Simple navigation

## 📡 API Endpoints

The frontend connects to the following backend endpoints:

### Authentication
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/logout` - User logout
- `GET /api/v1/auth/me` - Get current user

### Organizations
- `GET /api/v1/organizations` - List all organizations
- `POST /api/v1/organizations` - Create organization
- `PUT /api/v1/organizations/:id` - Update organization
- `DELETE /api/v1/organizations/:id` - Delete organization

### Users
- `GET /api/v1/users` - List all users
- `POST /api/v1/users` - Create user
- `PUT /api/v1/users/:id` - Update user
- `DELETE /api/v1/users/:id` - Delete user

### Contacts
- `GET /api/v1/contacts` - List all contacts
- `POST /api/v1/contacts` - Create contact
- `PUT /api/v1/contacts/:id` - Update contact
- `DELETE /api/v1/contacts/:id` - Delete contact
- `POST /api/v1/contacts/import` - Import contacts via CSV

### Audiences
- `GET /api/v1/audiences` - List all audiences
- `POST /api/v1/audiences` - Create audience
- `PUT /api/v1/audiences/:id` - Update audience
- `DELETE /api/v1/audiences/:id` - Delete audience
- `POST /api/v1/audiences/preview` - Preview audience filters

### Import Logs
- `GET /api/v1/contact_import_logs` - List import logs
- `GET /api/v1/contact_import_logs/:id` - Get import log details

## 🔧 Available Scripts

### `npm start`
Runs the app in development mode at `http://localhost:3001`

### `npm run build`
Builds the app for production to the `build` folder

### `npm test`
Launches the test runner in interactive watch mode

### `npm run eject`
**Note: this is a one-way operation. Once you eject, you can't go back!**

## 🔐 Authentication Flow

1. User logs in with email and password
2. Backend returns JWT token and user data
3. Token is stored in `localStorage`
4. Token is included in all API requests via axios interceptor
5. On 401 responses, user is redirected to login page

## 🎯 State Management

- **Redux Toolkit** for global state management
- **Auth Slice** manages authentication state
- Components use `useSelector` to access state
- Components use `useDispatch` to update state

## 🛡️ Security Features

- JWT token-based authentication
- Automatic token refresh on API calls
- Role-based route protection
- XSS protection through React
- CORS configured on backend

## 📱 Responsive Design

The application is fully responsive and works on:
- Desktop (1920px and above)
- Laptop (1366px - 1919px)
- Tablet (768px - 1365px)
- Mobile (320px - 767px)

## 🐛 Troubleshooting

### Backend Connection Issues
If you see "Network Error" or API call failures:
1. Ensure backend is running on `http://localhost:3000`
2. Check CORS configuration in backend
3. Verify `.env` file has correct `REACT_APP_API_URL`

### Authentication Issues
If login fails:
1. Verify credentials are correct
2. Check if user status is "active" in database
3. Ensure JWT_SECRET is set in backend `.env`

### Build Issues
If build fails:
1. Delete `node_modules` folder
2. Delete `package-lock.json`
3. Run `npm install` again
4. Run `npm run build`

## 📦 Dependencies

### Core
- `react` ^18.2.0
- `react-dom` ^18.2.0
- `react-router-dom` ^6.21.1

### State Management
- `@reduxjs/toolkit` ^2.0.1
- `react-redux` ^9.1.0

### HTTP Client
- `axios` ^1.6.5

### Build Tool
- `react-scripts` 5.0.1

## 🚀 Deployment

### Deploy to Production

1. **Build the application**
   ```bash
   npm run build
   ```

2. **Deploy to hosting service**
   - Netlify: Connect repository and deploy
   - Vercel: Connect repository and deploy
   - AWS S3: Upload build folder contents
   - Firebase: Use Firebase CLI

3. **Update environment variables**
   Set `REACT_APP_API_URL` to production API URL

## 📝 Additional Information

### Code Style
- Functional components with hooks
- Small, reusable components
- Clear separation of concerns
- Consistent naming conventions

### Best Practices Implemented
- Component-based architecture
- Service layer for API calls
- Centralized state management
- Utility functions for common operations
- CSS modules for styling
- Error handling and loading states
- Form validation
- Responsive design

### Future Enhancements
- Real-time notifications
- Advanced filtering for tables
- Export functionality (CSV, PDF)
- Dashboard analytics and charts
- Email campaign scheduling
- Multi-language support

## 📞 Support

For issues or questions:
1. Check the Troubleshooting section
2. Review the backend API documentation
3. Check console for error messages

## 📄 License

This project is part of the Real Estate Marketing CRM system.

---

**Note**: Make sure the backend API is running before starting the frontend application.
