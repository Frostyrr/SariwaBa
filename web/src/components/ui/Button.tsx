import React from 'react';

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'white' | 'dark';
  size?: 'sm' | 'md' | 'lg';
  icon?: React.ReactNode;
  iconPosition?: 'left' | 'right';
  fullWidth?: boolean;
}

const variantStyles: Record<string, string> = {
  primary:
    'bg-[#0066ff] text-white shadow-md shadow-blue-500/20 hover:bg-[#0052cc] hover:shadow-lg hover:shadow-blue-500/25 active:scale-[0.98]',
  secondary:
    'bg-blue-50 text-[#0066ff] border border-blue-200 hover:bg-blue-100/80 active:scale-[0.98]',
  outline:
    'bg-white/80 backdrop-blur-xs text-slate-800 border border-slate-300 hover:border-[#0066ff] hover:text-[#0066ff] hover:bg-white active:scale-[0.98]',
  ghost:
    'bg-transparent text-slate-600 hover:text-black hover:bg-slate-100/60 active:scale-[0.98]',
  white:
    'bg-white text-[#0066ff] shadow-sm border border-slate-200 hover:bg-slate-50 hover:shadow active:scale-[0.98]',
  dark:
    'bg-slate-900 text-white hover:bg-black active:scale-[0.98]',
};

const sizeStyles: Record<string, string> = {
  sm: 'text-xs font-bold uppercase tracking-wider px-4 py-2 h-9 gap-1.5',
  md: 'text-xs sm:text-sm font-bold uppercase tracking-wider px-6 py-2.5 h-11 gap-2',
  lg: 'text-sm font-bold uppercase tracking-wider px-8 py-3.5 h-13 gap-2.5',
};

export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  icon,
  iconPosition = 'left',
  fullWidth = false,
  className = '',
  disabled,
  ...props
}) => {
  return (
    <button
      disabled={disabled}
      className={`inline-flex items-center justify-center rounded-full font-heading transition-all duration-200 cursor-pointer select-none disabled:opacity-50 disabled:cursor-not-allowed ${
        variantStyles[variant]
      } ${sizeStyles[size]} ${fullWidth ? 'w-full' : ''} ${className}`}
      {...props}
    >
      {icon && iconPosition === 'left' && <span className="inline-flex shrink-0 items-center justify-center">{icon}</span>}
      <span>{children}</span>
      {icon && iconPosition === 'right' && <span className="inline-flex shrink-0 items-center justify-center">{icon}</span>}
    </button>
  );
};


