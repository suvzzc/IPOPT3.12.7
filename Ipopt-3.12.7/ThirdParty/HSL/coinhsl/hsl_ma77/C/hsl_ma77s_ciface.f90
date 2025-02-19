!
! COPYRIGHT (c) 2011 Science and Technology Facilities Council
! Original date 18 May 2011
!
! Written by: Jonathan Hogg and Jennifer Scott
!

module hsl_ma77_single_iface
   use iso_c_binding
   use hsl_ma77_single, only :                        &
      f_ma77_keep          => ma77_keep,           &
      f_ma77_control       => ma77_control,        &
      f_ma77_info          => ma77_info,           &
      f_ma77_open          => ma77_open,           &
      f_ma77_input_vars    => ma77_input_vars,     &
      f_ma77_input_reals   => ma77_input_reals,    &
      f_ma77_analyse       => ma77_analyse,        &
      f_ma77_factor        => ma77_factor,         &
      f_ma77_factor_solve  => ma77_factor_solve,   &
      f_ma77_solve         => ma77_solve,          &
      f_ma77_resid         => ma77_resid,          &
      f_ma77_scale         => ma77_scale,          &
      f_ma77_enquire_posdef=> ma77_enquire_posdef, &
      f_ma77_enquire_indef => ma77_enquire_indef,  &
      f_ma77_alter         => ma77_alter,          &
      f_ma77_restart       => ma77_restart,        &
      f_ma77_finalise      => ma77_finalise,       &
      f_ma77_solve_fredholm=> ma77_solve_fredholm, &
      f_ma77_lmultiply     => ma77_lmultiply
   implicit none

   ! Data type for user controls
   type, bind(C) :: ma77_control
      ! C/Fortran interface related controls
      integer(C_INT) :: f_arrays ! 0 is false, otherwise is true

      ! Printing controls
      integer(C_INT)  :: print_level
      integer(C_INT)  :: unit_diagnostics
      integer(C_INT)  :: unit_error
      integer(C_INT)  :: unit_warning

      ! Controls used by MA77_open
      integer(C_INT)  :: bits
      integer(C_INT)  :: buffer_lpage(2)
      integer(C_INT)  :: buffer_npage(2)
      integer(C_LONG) :: file_size
      integer(C_LONG) :: maxstore
      integer(C_LONG) :: storage(3)

      ! Controls used by MA77_analyse
      integer(C_INT)  :: nemin

      ! Controls used by MA77_scale
      integer(C_INT)  :: maxit
      integer(C_INT)  :: infnorm
      real(C_FLOAT)  :: thresh

      ! Controls used by MA77_factor with posdef true
      integer(C_INT)  :: nb54

      ! Controls used by MA77_factor with posdef false
      integer(C_INT)  :: action ! 0 is false, otherwise is true
      real(C_FLOAT)  :: multiplier
      integer(C_INT)  :: nb64
      integer(C_INT)  :: nbi
      real(C_FLOAT)  :: small
      real(C_FLOAT)  :: static
      integer(C_LONG) :: storage_indef
      real(C_FLOAT)  :: u
      real(C_FLOAT)  :: umin

      ! Controls used by ma77_solve_fredholm
      real(C_FLOAT) :: consist_tol
      
      ! Padding for future growth
      integer(C_INT) :: ispare(5)
      integer(C_LONG) :: lspare(5)
      real(C_FLOAT) :: rspare(5)
   end type ma77_control

   !*************************************************

   ! data type for returning information to user.
   type, bind(C) :: ma77_info
      real(C_FLOAT)  :: detlog
      integer(C_INT)  :: detsign
      integer(C_INT)  :: flag
      integer(C_INT)  :: iostat
      integer(C_INT)  :: matrix_dup
      integer(C_INT)  :: matrix_rank
      integer(C_INT)  :: matrix_outrange
      integer(C_INT)  :: maxdepth
      integer(C_INT)  :: maxfront
      integer(C_LONG) :: minstore
      integer(C_INT)  :: ndelay
      integer(C_LONG) :: nfactor
      integer(C_LONG) :: nflops
      integer(C_INT)  :: niter
      integer(C_INT)  :: nsup
      integer(C_INT)  :: num_neg
      integer(C_INT)  :: num_nothresh
      integer(C_INT)  :: num_perturbed
      integer(C_INT)  :: ntwo
      integer(C_INT)  :: stat
      integer(C_INT)  :: index(4)
      integer(C_LONG) :: nio_read(2)
      integer(C_LONG) :: nio_write(2)
      integer(C_LONG) :: nwd_read(2)
      integer(C_LONG) :: nwd_write(2)
      integer(C_INT)  :: num_file(4)
      integer(C_LONG) :: storage(4)
      integer(C_INT)  :: tree_nodes
      integer(C_INT)  :: unit_restart
      integer(C_INT)  :: unused
      real(C_FLOAT)  :: usmall
      
      ! Padding for future growth
      integer(C_INT) :: ispare(5)
      integer(C_LONG) :: lspare(5)
      real(C_FLOAT) :: rspare(5)
   end type ma77_info

   interface
      integer(C_INT) pure function strlen(cstr) bind(C)
         use iso_c_binding
         implicit none
         type(C_PTR), value, intent(in) :: cstr
      end function strlen
   end interface  
contains
   function cstr_to_fchar(cstr) result(fchar)
      type(C_PTR) :: cstr
      character(kind=C_CHAR,len=strlen(cstr)) :: fchar

      integer :: i
      character(C_CHAR), dimension(:), pointer :: temp

      call C_F_POINTER(cstr, temp, shape = (/ strlen(cstr) /) )

      do i = 1, size(temp)
         fchar(i:i) = temp(i)
      end do
   end function cstr_to_fchar

   subroutine copy_control_in(ccontrol, fcontrol, f_arrays)
      type(ma77_control), intent(in) :: ccontrol
      type(f_ma77_control), intent(out) :: fcontrol
      logical, intent(out) :: f_arrays

      f_arrays                   = (ccontrol%f_arrays .ne. 0)
      fcontrol%action            = (ccontrol%action .ne. 0)
      fcontrol%bits              = ccontrol%bits
      fcontrol%buffer_lpage(1:2) = ccontrol%buffer_lpage(1:2)
      fcontrol%buffer_npage(1:2) = ccontrol%buffer_npage(1:2)
      fcontrol%consist_tol       = ccontrol%consist_tol
      fcontrol%file_size         = ccontrol%file_size
      fcontrol%infnorm           = ccontrol%infnorm
      fcontrol%maxit             = ccontrol%maxit
      fcontrol%maxstore          = ccontrol%maxstore
      fcontrol%multiplier        = ccontrol%multiplier
      fcontrol%nb54              = ccontrol%nb54
      fcontrol%nb64              = ccontrol%nb64
      fcontrol%nbi               = ccontrol%nbi
      fcontrol%nemin             = ccontrol%nemin
      fcontrol%print_level       = ccontrol%print_level
      fcontrol%small             = ccontrol%small
      fcontrol%static            = ccontrol%static
      fcontrol%storage(1:3)      = ccontrol%storage(1:3)
      fcontrol%storage_indef     = ccontrol%storage_indef
      fcontrol%thresh            = ccontrol%thresh
      fcontrol%unit_diagnostics  = ccontrol%unit_diagnostics
      fcontrol%unit_error        = ccontrol%unit_error
      fcontrol%unit_warning      = ccontrol%unit_warning
      fcontrol%u                 = ccontrol%u
      fcontrol%umin              = ccontrol%umin
   end subroutine copy_control_in

   subroutine copy_info_out(finfo, cinfo)
      type(f_ma77_info), intent(in) :: finfo
      type(ma77_info), intent(out) :: cinfo

      cinfo%detlog         = finfo%detlog
      cinfo%detsign        = finfo%detsign
      cinfo%flag           = finfo%flag
      cinfo%iostat         = finfo%iostat
      cinfo%matrix_dup     = finfo%matrix_dup
      cinfo%matrix_rank    = finfo%matrix_rank
      cinfo%matrix_outrange= finfo%matrix_outrange
      cinfo%maxdepth       = finfo%maxdepth
      cinfo%maxfront       = finfo%maxfront
      cinfo%minstore       = finfo%minstore
      cinfo%ndelay         = finfo%ndelay
      cinfo%nfactor        = finfo%nfactor
      cinfo%nflops         = finfo%nflops
      cinfo%niter          = finfo%niter
      cinfo%nsup           = finfo%nsup
      cinfo%num_neg        = finfo%num_neg
      cinfo%num_nothresh   = finfo%num_nothresh
      cinfo%num_perturbed  = finfo%num_perturbed
      cinfo%ntwo           = finfo%ntwo
      cinfo%stat           = finfo%stat
      cinfo%index(1:4)     = finfo%index(1:4)
      cinfo%nio_read(1:2)  = finfo%nio_read(1:2)
      cinfo%nio_write(1:2) = finfo%nio_write(1:2)
      cinfo%nwd_read(1:2)  = finfo%nwd_read(1:2)
      cinfo%nwd_write(1:2) = finfo%nwd_write(1:2)
      cinfo%num_file(1:4)  = finfo%num_file(1:4)
      cinfo%storage(1:4)   = finfo%storage(1:4)
      cinfo%tree_nodes     = finfo%tree_nodes
      cinfo%unit_restart   = finfo%unit_restart
      cinfo%unused         = finfo%unused
      cinfo%usmall         = finfo%u
   end subroutine copy_info_out

   subroutine ma77_open_main(n, cfname1, cfname2, cfname3, cfname4, ckeep, &
         ccontrol, cinfo, nelt)

      integer(C_INT), intent(in) :: n
      type(C_PTR), intent(in) :: cfname1
      type(C_PTR), intent(in) :: cfname2
      type(C_PTR), intent(in) :: cfname3
      type(C_PTR), intent(in) :: cfname4
      type(C_PTR), intent(out) :: ckeep
      type(ma77_control), intent(in) :: ccontrol
      type(ma77_info), intent(inout) :: cinfo
      integer(C_INT), optional, intent(in) :: nelt

      type(f_ma77_keep), pointer :: fkeep
      type(f_ma77_control) :: fcontrol
      type(f_ma77_info) :: finfo
      character( kind=C_CHAR, len = max( &
         strlen(cfname1),strlen(cfname2),strlen(cfname3),strlen(cfname4) ) &
         ), dimension(4) :: fname
      logical :: f_arrays

      ! Copy data in and associate pointers correctly
      call copy_control_in(ccontrol, fcontrol, f_arrays)
      fname(1) = cstr_to_fchar(cfname1)
      fname(2) = cstr_to_fchar(cfname2)
      fname(3) = cstr_to_fchar(cfname3)
      fname(4) = cstr_to_fchar(cfname4)

      ! Allocate space to store keep and arrange a C pointer to it
      allocate(fkeep)
      ckeep = c_loc(fkeep)

      ! Call the Fortran routine
      call f_ma77_open(n, fname, fkeep, fcontrol, finfo, nelt=nelt)

      ! Copy information out to C structure
      call copy_info_out(finfo, cinfo)

   end subroutine ma77_open_main

end module

subroutine ma77_default_control_s(ccontrol) bind(C)
   use hsl_ma77_single_iface
   implicit none

   type(ma77_control), intent(out) :: ccontrol

   type(f_ma77_control) :: fdefault

   ccontrol%f_arrays = 0 ! false
   if( fdefault%action ) then
      ccontrol%action = 1 ! true
   else
      ccontrol%action = 0 ! false
   endif
   ccontrol%bits = fdefault%bits
   ccontrol%buffer_lpage(:) = fdefault%buffer_lpage(:)
   ccontrol%buffer_npage(:) = fdefault%buffer_npage(:)
   ccontrol%file_size = fdefault%file_size
   ccontrol%infnorm = fdefault%infnorm
   ccontrol%maxit = fdefault%maxit
   ccontrol%maxstore = fdefault%maxstore
   ccontrol%multiplier = fdefault%multiplier
   ccontrol%nb54 = fdefault%nb54
   ccontrol%nb64 = fdefault%nb64
   ccontrol%nbi = fdefault%nbi
   ccontrol%nemin = fdefault%nemin
   ccontrol%print_level = fdefault%print_level
   ccontrol%small = fdefault%small
   ccontrol%static = fdefault%static
   ccontrol%storage(:) = fdefault%storage(:)
   ccontrol%storage_indef = fdefault%storage_indef
   ccontrol%thresh = fdefault%thresh
   ccontrol%unit_diagnostics = fdefault%unit_diagnostics
   ccontrol%unit_error = fdefault%unit_error
   ccontrol%unit_warning = fdefault%unit_warning
   ccontrol%u = fdefault%u
   ccontrol%umin = fdefault%umin
end subroutine ma77_default_control_s

subroutine ma77_open_s(n, cfname1, cfname2, cfname3, cfname4, ckeep, &
      ccontrol, cinfo) bind(c)
   use hsl_ma77_single_iface
   implicit none

   integer(C_INT), value, intent(in) :: n
   type(C_PTR), value, intent(in) :: cfname1
   type(C_PTR), value, intent(in) :: cfname2
   type(C_PTR), value, intent(in) :: cfname3
   type(C_PTR), value, intent(in) :: cfname4
   type(C_PTR), intent(out) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo

   call ma77_open_main(n, cfname1, cfname2, cfname3, cfname4, ckeep, &
      ccontrol, cinfo)
end subroutine ma77_open_s

subroutine ma77_open_nelt_s(n, cfname1, cfname2, cfname3, cfname4, ckeep, &
      ccontrol, cinfo, nelt) bind(c)
   use hsl_ma77_single_iface
   implicit none

   integer(C_INT), value, intent(in) :: n
   type(C_PTR), value, intent(in) :: cfname1
   type(C_PTR), value, intent(in) :: cfname2
   type(C_PTR), value, intent(in) :: cfname3
   type(C_PTR), value, intent(in) :: cfname4
   type(C_PTR), intent(out) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo
   integer(C_INT), value, intent(in) :: nelt

   call ma77_open_main(n, cfname1, cfname2, cfname3, cfname4, ckeep, &
      ccontrol, cinfo, nelt=nelt)
end subroutine ma77_open_nelt_s

subroutine ma77_input_vars_s(cindex, nvar, clist, ckeep, ccontrol, cinfo) &
      bind(C)
   use hsl_ma77_single_iface
   implicit none

   integer(C_INT), value, intent(in) :: cindex
   integer(C_INT), value, intent(in) :: nvar
   type(C_PTR), value, intent(in) :: clist
   type(C_PTR), intent(inout) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo

   integer :: findex
   type(f_ma77_keep), pointer :: fkeep
   integer(C_INT), dimension(:), pointer :: flist
   integer, dimension(:), allocatable, target :: flist_alloc
   type(f_ma77_info) :: finfo
   type(f_ma77_control) :: fcontrol
   logical :: f_arrays

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   findex = cindex
   if(.not.f_arrays) findex = findex+1
   call C_F_POINTER(ckeep, fkeep)
   call C_F_POINTER(clist, flist, shape = (/ nvar /) )
   if(.not.f_arrays) then
      allocate(flist_alloc(nvar))
      flist_alloc(:) = flist(:) + 1
      flist => flist_alloc
   endif

   ! Call the Fortran routine
   call f_ma77_input_vars(findex, nvar, flist, fkeep, fcontrol, finfo)

   ! Copy information out to C structure
   call copy_info_out(finfo, cinfo)
end subroutine ma77_input_vars_s

subroutine ma77_input_reals_s(cindex, length, creals, ckeep, ccontrol, cinfo) &
      bind(C)
   use hsl_ma77_single_iface
   implicit none

   integer(C_INT), value, intent(in) :: cindex
   integer(C_INT), value, intent(in) :: length
   type(C_PTR), value, intent(in) :: creals
   type(C_PTR), intent(inout) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo

   integer :: findex
   type(f_ma77_keep), pointer :: fkeep
   real(C_FLOAT), dimension(:), pointer :: freals
   type(f_ma77_info) :: finfo
   type(f_ma77_control) :: fcontrol
   logical :: f_arrays

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   findex = cindex
   if(.not.f_arrays) findex = findex+1
   call C_F_POINTER(ckeep, fkeep)
   call C_F_POINTER(creals, freals, shape = (/ length /) )

   ! Call the Fortran routine
   call f_ma77_input_reals(findex, length, freals, fkeep, fcontrol, finfo)

   ! Copy information out to C structure
   call copy_info_out(finfo, cinfo)
end subroutine ma77_input_reals_s

subroutine ma77_analyse_s(corder, ckeep, ccontrol, cinfo) bind(C)
   use hsl_ma77_single_iface
   implicit none

   type(C_PTR), value, intent(in) :: corder
   type(C_PTR), intent(inout) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo

   type(f_ma77_keep), pointer :: fkeep
   integer(C_INT), dimension(:), pointer :: forder
   integer, dimension(:), allocatable, target :: forder_alloc
   type(f_ma77_info) :: finfo
   type(f_ma77_control) :: fcontrol
   logical :: f_arrays

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   call C_F_POINTER(ckeep, fkeep)
   call C_F_POINTER(corder, forder, shape = (/ fkeep%n /) )
   if(.not.f_arrays) then
      allocate(forder_alloc(fkeep%n))
      forder_alloc(:) = forder(:) + 1
      forder => forder_alloc
   endif

   ! Call the Fortran routine
   call f_ma77_analyse(forder, fkeep, fcontrol, finfo)

   ! Copy information out to C structure
   call copy_info_out(finfo, cinfo)
end subroutine ma77_analyse_s

subroutine ma77_factor_s(cposdef, ckeep, ccontrol, cinfo, cscale) bind(C)
   use hsl_ma77_single_iface
   implicit none

   integer(C_INT), value, intent(in) :: cposdef
   type(C_PTR), intent(inout) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo
   type(C_PTR), value, intent(in) :: cscale

   logical :: fposdef
   type(f_ma77_keep), pointer :: fkeep
   type(f_ma77_info) :: finfo
   type(f_ma77_control) :: fcontrol
   logical :: f_arrays
   real(C_FLOAT), dimension(:), pointer :: fscale

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   call C_F_POINTER(ckeep, fkeep)
   fposdef = (cposdef.ne.0)
   if(C_ASSOCIATED(cscale)) then
      call C_F_POINTER(cscale, fscale, shape = (/ fkeep%n /) )
   else
      nullify(fscale)
   endif

   ! Call the Fortran routine
   if(associated(fscale)) then
      call f_ma77_factor(fposdef, fkeep, fcontrol, finfo, scale=fscale)
   else
      call f_ma77_factor(fposdef, fkeep, fcontrol, finfo)
   endif

   ! Copy information out to C structure
   call copy_info_out(finfo, cinfo)
end subroutine ma77_factor_s

subroutine ma77_factor_solve_s(cposdef, ckeep, ccontrol, cinfo, cscale, &
      nrhs, lx, cx) bind(C)
   use hsl_ma77_single_iface
   implicit none

   integer(C_INT), value, intent(in) :: cposdef
   type(C_PTR), intent(inout) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo
   type(C_PTR), value, intent(in) :: cscale
   integer(C_INT), value, intent(in) :: nrhs
   integer(C_INT), value, intent(in) :: lx
   type(C_PTR), value :: cx

   logical :: fposdef
   real(C_FLOAT), dimension(:,:), pointer :: fx
   type(f_ma77_keep), pointer :: fkeep
   type(f_ma77_info) :: finfo
   type(f_ma77_control) :: fcontrol
   logical :: f_arrays
   real(C_FLOAT), dimension(:), pointer :: fscale

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   call C_F_POINTER(ckeep, fkeep)
   fposdef = (cposdef.ne.0)
   call C_F_POINTER(cx, fx, shape = (/ lx, nrhs /) )
   if(C_ASSOCIATED(cscale)) then
      call C_F_POINTER(cscale, fscale, shape = (/ fkeep%n /) )
   else
      nullify(fscale)
   endif

   ! Call the Fortran routine
   if(associated(fscale)) then
      call f_ma77_factor_solve(fposdef, fkeep, fcontrol, finfo, nrhs, lx, fx, &
         scale=fscale)
   else
      call f_ma77_factor_solve(fposdef, fkeep, fcontrol, finfo, nrhs, lx, fx)
   endif

   ! Copy information out to C structure
   call copy_info_out(finfo, cinfo)
end subroutine ma77_factor_solve_s

subroutine ma77_solve_s(job, nrhs, lx, cx, ckeep, ccontrol, cinfo, cscale) &
      bind(C)
   use hsl_ma77_single_iface
   implicit none

   integer(C_INT), value, intent(in) :: job
   integer(C_INT), value, intent(in) :: nrhs
   integer(C_INT), value, intent(in) :: lx
   type(C_PTR), value :: cx
   type(C_PTR), intent(inout) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo
   type(C_PTR), value, intent(in) :: cscale

   real(C_FLOAT), dimension(:,:), pointer :: fx
   type(f_ma77_keep), pointer :: fkeep
   type(f_ma77_info) :: finfo
   type(f_ma77_control) :: fcontrol
   logical :: f_arrays
   real(C_FLOAT), dimension(:), pointer :: fscale

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   call C_F_POINTER(ckeep, fkeep)
   call C_F_POINTER(cx, fx, shape = (/ lx, nrhs /) )
   if(C_ASSOCIATED(cscale)) then
      call C_F_POINTER(cscale, fscale, shape = (/ fkeep%n /) )
   else
      nullify(fscale)
   endif

   ! Copy data in and associate pointers correctly
   if(job.eq.0) then
      if(associated(fscale)) then
         call f_ma77_solve(nrhs, lx, fx, fkeep, fcontrol, finfo, scale=fscale)
      else
         call f_ma77_solve(nrhs, lx, fx, fkeep, fcontrol, finfo)
      endif
   else
      if(associated(fscale)) then
         call f_ma77_solve(nrhs, lx, fx, fkeep, fcontrol, finfo, scale=fscale, &
            job=job)
      else
         call f_ma77_solve(nrhs, lx, fx, fkeep, fcontrol, finfo, job=job)
      endif
   endif

   ! Call the Fortran routine
   call copy_info_out(finfo, cinfo)
end subroutine ma77_solve_s

subroutine ma77_resid_s(nrhs, lx, cx, lresid, cresid, ckeep, ccontrol, cinfo, &
      canorm_bnd) bind(C)
   use hsl_ma77_single_iface
   implicit none

   integer(C_INT), value, intent(in) :: nrhs
   integer(C_INT), value, intent(in) :: lx
   type(C_PTR), value, intent(in) :: cx
   integer(C_INT), value, intent(in) :: lresid
   type(C_PTR), value :: cresid
   type(C_PTR), intent(inout) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo
   type(C_PTR), value, intent(in) :: canorm_bnd ! optional

   real(C_FLOAT), dimension(:,:), pointer :: fx, fresid
   type(f_ma77_keep), pointer :: fkeep
   type(f_ma77_info) :: finfo
   type(f_ma77_control) :: fcontrol
   real(C_FLOAT), pointer :: fanorm_bnd
   logical :: f_arrays

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   call C_F_POINTER(ckeep, fkeep)
   call C_F_POINTER(cx, fx, shape = (/ lx, nrhs /) )
   call C_F_POINTER(cresid, fresid, shape = (/  lresid, nrhs /) )
   if(C_ASSOCIATED(canorm_bnd)) then
      call C_F_POINTER(canorm_bnd, fanorm_bnd)
   else
      nullify(fanorm_bnd)
   endif

   ! Call the Fortran routine
   if(associated(fanorm_bnd) ) then
      call f_ma77_resid(nrhs, lx, fx, lresid, fresid, fkeep, fcontrol, &
         finfo, anorm_bnd=fanorm_bnd)
   else
      call f_ma77_resid(nrhs, lx, fx, lresid, fresid, fkeep, fcontrol, &
         finfo)
   endif

   ! Copy information out to C structure
   call copy_info_out(finfo, cinfo)
end subroutine ma77_resid_s

subroutine ma77_scale_s(cscale, ckeep, ccontrol, cinfo, canorm) bind(C)
   use hsl_ma77_single_iface
   implicit none

   type(C_PTR), value, intent(in) :: cscale
   type(C_PTR), intent(inout) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo
   type(C_PTR), value, intent(in) :: canorm ! optional

   real(C_FLOAT), dimension(:), pointer :: fscale
   type(f_ma77_keep), pointer :: fkeep
   type(f_ma77_info) :: finfo
   type(f_ma77_control) :: fcontrol
   real(C_FLOAT), pointer :: fanorm
   logical :: f_arrays

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   call C_F_POINTER(ckeep, fkeep)
   call C_F_POINTER(cscale, fscale, shape = (/ fkeep%n /) )
   if(C_ASSOCIATED(canorm)) then
      call C_F_POINTER(canorm, fanorm)
   else
      nullify(fanorm)
   endif

   ! Copy data in and associate pointers correctly
   if(associated(fanorm) ) then
      call f_ma77_scale(fscale, fkeep, fcontrol, finfo, anorm=fanorm)
   else
      call f_ma77_scale(fscale, fkeep, fcontrol, finfo)
   endif

   ! Call the Fortran routine
   call copy_info_out(finfo, cinfo)
end subroutine ma77_scale_s

subroutine ma77_enquire_posdef_s(cd, ckeep, ccontrol, cinfo) bind(C)
   use hsl_ma77_single_iface
   implicit none

   type(C_PTR), value, intent(in) :: cd
   type(C_PTR), intent(inout) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo

   real(C_FLOAT), dimension(:), pointer :: fd
   type(f_ma77_keep), pointer :: fkeep
   type(f_ma77_info) :: finfo
   type(f_ma77_control) :: fcontrol
   logical :: f_arrays

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   call C_F_POINTER(ckeep, fkeep)
   call C_F_POINTER(cd, fd, shape = (/ fkeep%n /) )

   ! Copy data in and associate pointers correctly
   call f_ma77_enquire_posdef(fd, fkeep, fcontrol, finfo)

   ! Call the Fortran routine
   call copy_info_out(finfo, cinfo)
end subroutine ma77_enquire_posdef_s

subroutine ma77_enquire_indef_s(cpiv_order, cd, ckeep, ccontrol, cinfo) bind(C)
   use hsl_ma77_single_iface
   implicit none

   type(C_PTR), value, intent(in) :: cpiv_order
   type(C_PTR), value, intent(in) :: cd
   type(C_PTR), intent(inout) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo

   integer(C_INT), dimension(:), pointer :: fpiv_order
   real(C_FLOAT), dimension(:,:), pointer :: fd
   type(f_ma77_keep), pointer :: fkeep
   type(f_ma77_info) :: finfo
   type(f_ma77_control) :: fcontrol
   logical :: f_arrays

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   call C_F_POINTER(ckeep, fkeep)
   call C_F_POINTER(cpiv_order, fpiv_order, shape = (/ fkeep%n /) )
   call C_F_POINTER(cd, fd, shape = (/ 2, fkeep%n /) )

   ! Call the Fortran routine
   call f_ma77_enquire_indef(fpiv_order, fd, fkeep, fcontrol, finfo)

   ! Copy information out to C structure
   call copy_info_out(finfo, cinfo)

   ! Correct piv_order if using C indexing
   if(.not.f_arrays) then
      fpiv_order(:) = fpiv_order(:) - 1
   endif
end subroutine ma77_enquire_indef_s

subroutine ma77_alter_s(cd, ckeep, ccontrol, cinfo) bind(C)
   use hsl_ma77_single_iface
   implicit none

   type(C_PTR), intent(inout) :: ckeep
   type(C_PTR), value, intent(in) :: cd
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo

   real(C_FLOAT), dimension(:,:), pointer :: fd
   type(f_ma77_keep), pointer :: fkeep
   type(f_ma77_control) :: fcontrol
   type(f_ma77_info) :: finfo
   logical :: f_arrays

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   call C_F_POINTER(ckeep, fkeep)
   call C_F_POINTER(cd, fd, shape = (/ 2, fkeep%n /) )

   ! Copy data in and associate pointers correctly
   call f_ma77_alter(fd, fkeep, fcontrol, finfo)

   ! Call the Fortran routine
   call copy_info_out(finfo, cinfo)
end subroutine ma77_alter_s

subroutine ma77_restart_s(crestart_file, cfname1, cfname2, cfname3, cfname4, &
      ckeep, ccontrol, cinfo) bind(c)
   use hsl_ma77_single_iface
   implicit none

   type(C_PTR), intent(in) :: crestart_file
   type(C_PTR), intent(in) :: cfname1
   type(C_PTR), intent(in) :: cfname2
   type(C_PTR), intent(in) :: cfname3
   type(C_PTR), intent(in) :: cfname4
   type(C_PTR), intent(out) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo

   type(f_ma77_keep), pointer :: fkeep
   type(f_ma77_control) :: fcontrol
   type(f_ma77_info) :: finfo
   character( kind=C_CHAR, len = strlen(crestart_file) ) :: frestart_file
   character( kind=C_CHAR, len = max( &
      strlen(cfname1),strlen(cfname2),strlen(cfname3),strlen(cfname4) ) &
      ), dimension(4) :: fname
   logical :: f_arrays

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   call C_F_POINTER(ckeep, fkeep)
   frestart_file = cstr_to_fchar(crestart_file)
   fname(1) = cstr_to_fchar(cfname1)
   fname(2) = cstr_to_fchar(cfname2)
   fname(3) = cstr_to_fchar(cfname3)
   fname(4) = cstr_to_fchar(cfname4)

   ! Copy data in and associate pointers correctly
   call f_ma77_restart(frestart_file, fname, fkeep, fcontrol, finfo)

   ! Call the Fortran routine
   call copy_info_out(finfo, cinfo)
end subroutine ma77_restart_s

subroutine ma77_finalise_s(ckeep, ccontrol, cinfo) bind(C)
   use hsl_ma77_single_iface
   implicit none

   type(C_PTR), intent(inout) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo

   type(f_ma77_keep), pointer :: fkeep
   type(f_ma77_info) :: finfo
   type(f_ma77_control) :: fcontrol
   logical :: f_arrays

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   call C_F_POINTER(ckeep, fkeep)
   
   ! Call the Fortran routine
   call f_ma77_finalise(fkeep, fcontrol, finfo)

   ! Free memory
   deallocate(fkeep)
   ckeep = C_NULL_PTR

   ! Copy information out to C structure
   call copy_info_out(finfo, cinfo)
end subroutine ma77_finalise_s

subroutine ma77_solve_fredholm_s(nrhs, cflag_out, lx, cx, ckeep, ccontrol, &
      cinfo, cscale) bind(C)
   use hsl_ma77_single_iface
   implicit none

   integer(C_INT), value, intent(in) :: nrhs
   type(C_PTR), value :: cflag_out
   integer(C_INT), value, intent(in) :: lx
   type(C_PTR), value :: cx
   type(C_PTR), intent(inout) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo
   type(C_PTR), value, intent(in) :: cscale

   integer(C_INT), dimension(:), pointer :: fiflag_out
   logical, dimension(:), allocatable :: fflag_out
   real(C_FLOAT), dimension(:,:), pointer :: fx
   type(f_ma77_keep), pointer :: fkeep
   type(f_ma77_info) :: finfo
   type(f_ma77_control) :: fcontrol
   logical :: f_arrays
   real(C_FLOAT), dimension(:), pointer :: fscale

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   call C_F_POINTER(cflag_out, fiflag_out, shape = (/ nrhs /) )
   allocate(fflag_out(nrhs))
   call C_F_POINTER(ckeep, fkeep)
   call C_F_POINTER(cx, fx, shape = (/ lx, 2*nrhs /) )
   if(C_ASSOCIATED(cscale)) then
      call C_F_POINTER(cscale, fscale, shape = (/ fkeep%n /) )
   else
      nullify(fscale)
   endif

   ! Call the Fortran routine
   if(associated(fscale)) then
      call f_ma77_solve_fredholm(nrhs, fflag_out, lx, fx, fkeep, fcontrol, &
         finfo, scale=fscale)
   else
      call f_ma77_solve_fredholm(nrhs, fflag_out, lx, fx, fkeep, fcontrol, &
         finfo)
   endif

   ! Copy data out
   call copy_info_out(finfo, cinfo)
   where(fflag_out(:))
      fiflag_out(:) = 1 ! True
   elsewhere
      fiflag_out(:) = 0 ! False
   endwhere
end subroutine ma77_solve_fredholm_s

subroutine ma77_lmultiply_s(ctrans, k, lx, cx, ly, cy, ckeep, ccontrol, cinfo, &
      cscale) bind(C)
   use hsl_ma77_single_iface
   implicit none

   integer(C_INT), value :: ctrans
   integer(C_INT), value :: k
   integer(C_INT), value, intent(in) :: lx
   type(C_PTR), value :: cx
   integer(C_INT), value, intent(in) :: ly
   type(C_PTR), value :: cy
   type(C_PTR), intent(inout) :: ckeep
   type(ma77_control), intent(in) :: ccontrol
   type(ma77_info), intent(inout) :: cinfo
   type(C_PTR), value, intent(in) :: cscale

   logical :: ftrans
   real(C_FLOAT), dimension(:,:), pointer :: fx
   real(C_FLOAT), dimension(:,:), pointer :: fy
   type(f_ma77_keep), pointer :: fkeep
   type(f_ma77_info) :: finfo
   type(f_ma77_control) :: fcontrol
   logical :: f_arrays
   real(C_FLOAT), dimension(:), pointer :: fscale

   ! Copy data in and associate pointers correctly
   call copy_control_in(ccontrol, fcontrol, f_arrays)
   ftrans = (ctrans.ne.0)
   call C_F_POINTER(ckeep, fkeep)
   call C_F_POINTER(cx, fx, shape = (/ lx, k /) )
   call C_F_POINTER(cy, fy, shape = (/ ly, k /) )
   if(C_ASSOCIATED(cscale)) then
      call C_F_POINTER(cscale, fscale, shape = (/ fkeep%n /) )
   else
      nullify(fscale)
   endif

   ! Call the Fortran routine
   if(associated(fscale)) then
      call f_ma77_lmultiply(ftrans, k, lx, fx, ly, fy, fkeep, fcontrol, &
         finfo, scale=fscale)
   else
      call f_ma77_lmultiply(ftrans, k, lx, fx, ly, fy, fkeep, fcontrol, &
         finfo)
   endif

   ! Copy data out
   call copy_info_out(finfo, cinfo)
end subroutine ma77_lmultiply_s
