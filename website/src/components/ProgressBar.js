import React from 'react';

export default function ProgressBar({ steps }) {
  const statusColors = {
    'not-started': {
      light: '#e0e0e0',
      dark: '#9e9e9e'
    },
    'started': {
      light: '#ffcc80',
      dark: '#ff9800'
    },
    'done': {
      light: '#ce93d8',
      dark: '#9c27b0'
    }
  };

  return (
    <div style={{
      display: 'flex',
      width: '100%',
      height: '24px', // Very thin
      borderRadius: '4px',
      overflow: 'hidden',
      marginTop: '16px',
      marginBottom: '16px',
      boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
    }}>
      {steps.map((step, index) => {
        const colors = statusColors[step.status] || statusColors['not-started'];
        const isLast = index === steps.length - 1;
        
        return (
          <div
            key={index}
            style={{
              flex: 1,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              background: `linear-gradient(135deg, ${colors.light} 0%, ${colors.dark} 100%)`,
              color: '#fff',
              borderRight: !isLast ? '1px solid rgba(255,255,255,0.3)' : 'none',
              padding: '0 8px',
              fontWeight: '500',
              fontSize: '12px',
              textShadow: '0 1px 1px rgba(0,0,0,0.2)',
              transition: 'all 0.3s ease'
            }}
          >
            {step.label}
          </div>
        );
      })}
    </div>
  );
}

